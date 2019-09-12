FactoryBot.define do
  factory :date_facet, class: DateFacet do
    key { "published_at" }
    filterable { true }
    type { "date" }
    display_as_result_metadata { true }
    initialize_with { new(attributes.deep_stringify_keys, {}) }
  end
end
