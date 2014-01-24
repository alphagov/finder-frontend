class Facet
  attr_accessor :name, :key, :value

  def initialize(attrs = {})
    @name = attrs[:name]
    @key = attrs[:key]
    @value = attrs[:value]
  end

  def to_partial_path
    self.class.name.underscore
  end
end
