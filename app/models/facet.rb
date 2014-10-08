class Facet
  attr_reader :name, :key, :preposition
  attr_accessor :value

  def initialize(attrs = {})
    @key = attrs[:key]
    @name = attrs[:name]
    self.value = attrs[:value].presence
    @preposition = attrs[:preposition]
  end

  def to_partial_path
    self.class.name.underscore
  end

  def selected_values
    []
  end
end
