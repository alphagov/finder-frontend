class Facet
  attr_reader :name, :key
  attr_accessor :value

  def initialize(attrs = {})
    @key = attrs[:key]
    @name = attrs[:name]
    @value = attrs[:value].presence
  end

  def to_partial_path
    self.class.name.underscore
  end
end
