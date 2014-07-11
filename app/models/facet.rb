class Facet
  attr_reader :name, :key, :preposition
  attr_accessor :value

  def initialize(attrs = {})
    @key = attrs[:key]
    @name = attrs[:name]
    @value = attrs[:value].presence
    @preposition = attrs[:preposition]
  end

  def to_partial_path
    self.class.name.underscore
  end

  def selected_values
    []
  end

  def selected_values_to_hash
    selected_values.map do | selected_value |
      { label: selected_value.label, value: selected_value.value }
    end
  end
end
