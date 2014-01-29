class Facet
  attr_reader :name, :key
  attr_accessor :value

  def self.from_hash(facet_hash)
    self.new(key: facet_hash['key'], name: facet_hash['name'], value: facet_hash['value'])
  end

  def initialize(attrs = {})
    @key = attrs[:key]
    @name = attrs[:name]
    @value = attrs[:value].presence
  end

  def to_partial_path
    self.class.name.underscore
  end
end
