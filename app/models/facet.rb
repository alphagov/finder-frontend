class Facet
  attr_accessor :schema, :name, :key, :value

  def initialize(schema, value = nil)
    @schema = schema
    @name = schema["name"]
    @key = schema["key"]
    @value = value.presence
    after_initialize
  end

  def to_partial_path
    self.class.name.underscore
  end

private
  def after_initialize
  end
end
