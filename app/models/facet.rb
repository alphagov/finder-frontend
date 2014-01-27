class Facet
  attr_accessor :name, :key, :value

  def initialize(schema, value = nil)
  end

  def to_partial_path
    self.class.name.underscore
  end
end
