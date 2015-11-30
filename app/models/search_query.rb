class SearchQuery
  attr_accessor :raw_query
  def initialize(query)
    raise ArgumentError, 'Query should be string' unless query.is_a? String
    @raw_query = query
  end
end
