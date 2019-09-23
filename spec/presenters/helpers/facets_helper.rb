require "spec_helper"

module FacetsHelper
  def a_facet
    double(
      OptionSelectFacet,
      key: "key_1",
      selected_values: [
      {
        "value" => "ca98-and-civil-cartels",
        "label" => "CA98 and civil cartels",
      },
      {
        "value" => "mergers",
        "label" => "Mergers",
      },
    ],
      allowed_values: [
      {
        "value" => "ca98-and-civil-cartels",
        "label" => "CA98 and civil cartels",
      },
      {
        "value" => "mergers",
        "label" => "Mergers",
      },
    ],
      sentence_fragment: {
      "key" => "key_1",
      "type" => "text",
      "preposition" => "Of Type",
      "values" => [
        {
          "label" => "CA98 and civil cartels",
        },
        {
          "label" => "Mergers",
        },
      ],
      "word_connectors" => { words_connector: "or" },
    },
      has_filters?: true,
      labels: %W(ca98-and-civil-cartels mergers),
      value: %W(ca98-and-civil-cartels mergers),
      hide_facet_tag?: false,
    )
  end

  def another_facet
    double(
      OptionSelectFacet,
      key: "key_2",
      preposition: "About",
      selected_values: [
      {
        "value" => "farming",
        "label" => "Farming",
      },
      {
        "value" => "chemicals",
        "label" => "Chemicals",
      },
    ],
      sentence_fragment: {
      "key" => "key_2",
      "type" => "text",
      "preposition" => "About",
      "values" => [
        {
          "label" => "Farming",
        },
        {
          "label" => "Chemicals",
        },
      ],
      "word_connectors" => { words_connector: "or" },
    },
      has_filters?: true,
      value: %w[farming chemicals],
      "word_connectors" => { words_connector: "or" },
      hide_facet_tag?: false,
    )
  end

  def a_date_facet
    double(
      OptionSelectFacet,
      "key" => "closed_date",
      sentence_fragment: nil,
      has_filters?: false,
      "word_connectors" => { words_connector: "or" },
      hide_facet_tag?: false,
    )
  end
end
