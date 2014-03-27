module FacetParser
  def self.parse(facet_hash)
    case facet_hash['type']
    when 'multi-select'
      SelectFacet.new(select_facet_attrs(facet_hash))
    when 'single-select'
      RadioFacet.new(select_facet_attrs(facet_hash))
    else
      raise ArgumentError.new("Unknown facet type: #{facet_hash['type']}")
    end
  end

private
  def self.with_base_facet_attrs(facet_hash, &subtype_attr_builder)
    {
      key: facet_hash['key'],
      name: facet_hash['name'],
      value: facet_hash['value']
    }.merge(subtype_attr_builder.call)
  end

  def self.select_facet_attrs(facet_hash)
    with_base_facet_attrs(facet_hash) do
      {
        include_blank: facet_hash['include_blank'],
        allowed_values: facet_hash['allowed_values'].map do | allowed_value_hash |
          build_allowed_value(allowed_value_hash.symbolize_keys)
        end
      }
    end
  end

  def self.build_allowed_value(attrs)
    OpenStruct.new(label: attrs[:label], value: attrs[:value], non_described: attrs[:non_described])
  end
end
