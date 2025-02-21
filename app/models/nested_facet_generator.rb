class NestedFacetGenerator
  attr_reader :facet_hash, :value_hash

  def initialize(facet_hash, value_hash)
    @facet_hash = facet_hash
    @value_hash = value_hash
  end

  def generate_facets
    [NestedFacet.new(main_facet_hash_without_sub_facets, value_hash[facet_hash["key"]]),
     NestedFacet.new(sub_facet_hash, value_hash[sub_facet_key])]
  end

private

  def main_facet_hash_without_sub_facets
    hash_dup = facet_hash.dup
    hash_dup["allowed_values"] = hash_dup["allowed_values"].map { |v| v.except("sub_facets") }
    hash_dup.delete("sub_facet_name")
    hash_dup.delete("sub_facet_key")
    hash_dup.delete("sub_facet_key")
    hash_dup.delete("nested_facet")

    hash_dup
  end

  def sub_facet_name
    facet_hash["sub_facet_name"]
  end

  def sub_facet_key
    facet_hash["sub_facet_key"]
  end

  def sub_facet_type
    facet_hash["type"]
  end

  def sub_facet_preposition
    facet_hash["preposition"]
  end

  def sub_facet_hash
    {
      "allowed_values" => facet_hash["allowed_values"].flat_map { |allowed_value| allowed_value["sub_facets"] || [] },
      "key" => sub_facet_key,
      "name" => sub_facet_name,
      "type" => sub_facet_type,
      "preposition" => sub_facet_preposition,
      "filterable" => true,
    }
  end
end
