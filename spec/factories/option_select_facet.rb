FactoryBot.define do
  factory :option_select_facet, class: OptionSelectFacet do
    key { "organisations" }
    filterable { true }
    type { "text" }
    display_as_result_metadata { true }
    transient do
      values { nil }
    end
    initialize_with {
      new(attributes.deep_stringify_keys, values)
    }
  end
end
