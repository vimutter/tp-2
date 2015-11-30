# Going from bottom to the top, this client is intended to use
# Model in order to get results. I.e. given query string this should return array of `Language`
class SearchQuery
  # Raw query
  attr_accessor :raw_query

  # Check that query is `String`
  def initialize(query)
    raise ArgumentError, 'Query should be string' unless query.is_a? String
    @raw_query = query
  end

  # Memorized parse query into hash of :positive
  # and :negative tokens
  # Positive are treated as OR
  # negative are treated as AND
  def parse
    @query ||= begin
      result = {}

      result[:negative] = normalize_tokens raw_query.scan /(?<=-)[^"\s]+|(?<=-)"[^"]+"/
      result[:positive] = normalize_tokens raw_query.scan /[^"\s]+|"[^"]+"/

      result
    end
  end

  # Returns `Language` Array based on several queries to `Language`
  def results
    query = parse

    results = []
    results << Language.where(name: query[:positive])
    results << Language.where(type: query[:positive])
    results << Language.where(designers: query[:positive])

    positive = results.flatten.uniq(&:name).index_by &:name

    results = []
    results << Language.where_not(name: query[:negative])
    results << Language.where_not(type: query[:negative])
    results << Language.where_not(designers: query[:negative])

    negative = results.flatten.uniq(&:name).index_by(&:name)

    negative.slice(*positive.keys).values
  end

  protected

  def normalize_tokens(tokens)
    tokens.map {|token| token =~ /\A"([^"]+)"\Z/ ? $1 : token }
  end

end
