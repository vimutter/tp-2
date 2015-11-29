# Language class. Intended to mock at some degree classic AR model.
# main points are .where and .where_not (yes, not.where it should be, but idea was to KISS)
#
class Language
  # Data in raw view. Simple Array of hashes, without any processing
  include LanguageData
  # Indexed data, plus source of fields mapping
  extend DataIndex

  FIELDS = DataIndex::FIELDS.keys
  ARRAY_FIELDS = [:type, :designers]
  SIMPLE_FIELDS = FIELDS - ARRAY_FIELDS
  attr_accessor *FIELDS

  class << self

    # Positive search
    def where(options = {})
      seach_by options
    end

    # Negative search
    def where_not(options = {})
      seach_by options, positive: false
    end

    protected

    # Extracted after .where_not was done by copying whole where and changing two lines
    def seach_by(fields, positive: true)
      results = name_index.dup
      method = positive ? :select : :reject

      fields.with_indifferent_access.slice(*FIELDS).each_pair do |field, filters|
        case filters
        when String
          results = filter_by_string(results, field, filters, method)
        when Array
          results = filter_by_array(results, field, filters, method)
        else
          raise ArgumentError, 'Value of filter should be String or Array'
        end
      end

      convert_raw_to_model results.values.flatten
    end

    # Extracted after language spec was green
    def filter_by_string(results, field, string, method)
      partial_results = index(field).public_send(method) do |(key, _)|
        key =~ /#{Regexp.escape(string)}/i
      end

      filter_index(results, partial_results)
    end

    # Extracted after language spec was green
    def filter_by_array(results, field, array, method)
      partial_results = index(field).public_send(method) do |(key, _)|
        array.any? do |filter|
          raise ArgumentError, 'Value of filter should be String or Array' unless filter.is_a? String

          key =~ /#{Regexp.escape(filter.to_s)}/i
        end
      end

      filter_index(results, partial_results)
    end

    # Extracted after .where spec was green
    def convert_raw_to_model(array)
      array.map do |hash|
        object = new
        ARRAY_FIELDS.each do |field|
          object.public_send :"#{field}=", make_array(hash[DataIndex::FIELDS[field]])
        end

        SIMPLE_FIELDS.each do |field|
          object.public_send :"#{field}=", hash[DataIndex::FIELDS[field]]
        end

        object
      end
    end

    # Extracted after .where spec was green
    def filter_index(index, values)
      names = values.map{|(key, values)| values}.flatten.map {|object| object[DataIndex::NAME] }.uniq
      index.slice(*names)
    end

    # Made to not spread meta-complxity over the code.
    def index(name)
      public_send(:"#{name}_index")
    end
  end
end