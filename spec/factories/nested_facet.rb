FactoryBot.define do
  factory :nested_facet, class: NestedFacet do
    key { "main_facet_key_value" }
    name { "Main Facet name" }
    sub_facet_key { "sub_facet_key_value" }
    sub_facet_name { "Sub Facet Name" }
    filterable { true }
    type { "nested" }
    nested_facet { true }
    display_as_result_metadata { true }
    transient do
      values { nil }
    end
    initialize_with do
      new(attributes.deep_stringify_keys, values)
    end
  end
end
