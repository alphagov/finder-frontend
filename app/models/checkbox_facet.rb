class CheckboxFacet < FilterableFacet
  attr_writer :value

  def sentence_fragment
    return nil unless is_checked?

    {
      'key' => key,
      'preposition' => preposition,
      'values' => [{
        'label' => short_name,
        'parameter_key' => key,
        'value' => value
      }],
      'word_connectors' => and_word_connectors
    }
  end

  def has_filters?
    is_checked?
  end

  def has_value?
    is_checked?
  end

  def value
    facet['value'] || true
  end

  def is_checked?
    @value.present?
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
        track_label: name
    }
  end
end
