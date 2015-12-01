require 'set'
# Going from bottom to the top, this client is intended to use
# Model in order to get results. I.e. given query string this should return array of `Language`
class SearchQuery
  # Raw query
  attr_accessor :raw_query

  NEGATIVE_COMPLEX = /(-"[^"]+")/
  NEGATIVE_COMPLEX_MARK = '-"'
  NEGATIVE_COMPLEX_RANGE = 2..-2

  POSITIVE_COMPLEX = /("[^"]+")/
  POSITIVE_COMPLEX_MARK = '"'
  POSITIVE_COMPLEX_RANGE = 1..-2

  NEGATIVE_SIMPLE = /(-[^"\s]+)/
  NEGATIVE_SIMPLE_MARK = '-'
  NEGATIVE_SIMPLE_RANGE = 1..-1

  POSITIVE_SIMPLE = /([^"\s]+)/

  # Check that query is `String`
  def initialize(query)
    raise ArgumentError, 'Query should be string' unless query.is_a? String
    @raw_query = query
  end

  # Memorized parse query into hash of :positive
  # and :negative tokens
  # Positive are treated as OR
  # negative are treated as AND
  #
  def parse
    @query ||= begin
      result = {negative: Set.new, positive: Set.new}

      to_continue = extract_type(result, raw_query, NEGATIVE_COMPLEX, NEGATIVE_COMPLEX_MARK, :negative, NEGATIVE_COMPLEX_RANGE)

      to_continue = to_continue.flat_map do |raw_query|
        extract_type(result, raw_query, POSITIVE_COMPLEX, POSITIVE_COMPLEX_MARK, :positive, POSITIVE_COMPLEX_RANGE)
      end

      to_continue = to_continue.flat_map do |raw_query|
        extract_type(result, raw_query, NEGATIVE_SIMPLE, NEGATIVE_SIMPLE_MARK, :negative, NEGATIVE_SIMPLE_RANGE)
      end

      to_continue.each do |raw_query|
        raw_query.split(POSITIVE_SIMPLE).each do |chunk|
          if chunk.present?
            result[:positive] << chunk
          end
        end
      end

      result
    end
  end

  # Returns `Language` Array based on several queries to `Language`
  def results
    query = parse

    results = []
    positive = query[:positive].to_a
    results << Language.where(name: positive)
    results << Language.where(type: positive)
    results << Language.where(designers: positive)

    weights = weight_results results

    positive = results.flatten.uniq(&:name).index_by &:name

    results = []
    negative = query[:negative].to_a

    results << Language.where_not(name: negative).map(&:name)
    results << Language.where_not(type: negative).map(&:name)
    results << Language.where_not(designers: negative).map(&:name)

    negative = results.inject(results[0]) {|result, array| result & array }.uniq

    final_results = positive.slice(*negative).values
    sort_results set_hits(final_results, weights), weights
  end

  protected

  # Extracted method from results. Ides - by given groups of results get weights of results.
  # If item fits
  def weight_results(results)
    weights = Hash.new { |hash, key| hash[key] = 0 }

    results.each do |set|
      set.each do |item|
        weights[item.name] += item.hits
      end
    end

    weights
  end

  # Set full hits value from all indexes
  def set_hits(results, weights)
    results.each {|item| item.hits = weights[item.name] }
  end

  #Sort by ful weight
  def sort_results(results, weights)
    results.sort_by {|item| weights[item.name] }.reverse
  end

  # Gets tokens by type from array of pieces of raw query string.
  # returns new pieces after removing fit tokens
  def extract_type(result, raw_query, regex, mark, destination, range)
    raw_query.split(regex).inject([]) do |raw_array, chunk|
      if chunk.starts_with?(mark)
        result[destination] << chunk[range]
      else
        raw_array << chunk.strip
      end

      raw_array
    end
  end

end
