module DataIndex
  NAME = 'Name'
  TYPE = 'Type'
  DESIGNERS = 'Designed by'
  SEPARATOR = ','
  FIELDS = {
    name: NAME,
    type: TYPE,
    designers: DESIGNERS
  }

  # Rewritten this with Const and cycle:
  # - Less code duplication
  # - Constant would be useful at Language model
  FIELDS.each_pair do |name, raw_name|

    define_method "#{name}_index" do
      index = instance_variable_get :"@#{name}_index"

      unless index
        index = build_index_by(raw_name)
        instance_variable_set :"@#{name}_index", index
      end

      index
    end
  end

  def make_array(value)
    value.split(SEPARATOR).map(&:strip)
  end

  protected

  def build_index_by(field)
    result = Hash.new { |hash, key| hash[key] = [] }
    self::DATA.inject(result) do |result, language|
      make_array(language[field]).each do |token|
        result[token] << language
      end
      result
    end
  end
end
