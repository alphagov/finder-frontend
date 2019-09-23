class CheckboxFacet < FilterableFacet
  def initialize(facet, checked)
    @checked = checked
    super(facet)
  end

  def sentence_fragment
    return nil unless is_checked?

    {
      "key" => key,
      "preposition" => preposition,
      "values" => [{
        "label" => short_name,
        "parameter_key" => key,
        "value" => value,
      }],
      "word_connectors" => and_word_connectors,
    }
  end

  def has_filters?
    is_checked?
  end

  def value
    facet["filter_value"] || true
  end

  def is_checked?
    @checked.present?
  end

  def checkbox_label
    facet["name"]
  end

  def id
    "checkbox_facet-#{key}_#{value}"
  end

  def data
    {
        track_category: "filterClicked",
        uncheck_track_category: "filterRemoved",
        track_action: "checkboxFacet",
        track_label: name,
    }
  end

  def query_params
    @checked ? { key => value } : {}
  end
end
