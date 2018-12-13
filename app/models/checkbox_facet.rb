class CheckboxFacet < FilterableFacet
  attr_writer :value

  def sentence_fragment
    return nil unless is_checked?

    {
      'type' => "text",
      'preposition' => preposition,
      'values' => [{
        'label' => label,
        'parameter_key' => key,
      }],
    }
  end

  def value
    facet['value']
  end

  def is_checked?
    @value.present?
  end

  def checkbox_label
    facet["checkbox_label"] || label
  end

  def label
    facet["label"]
  end

  def id
    "checkbox_facet-#{label}_#{value}"
  end

  def data
    {
        track_category: "filterClicked",
        track_action: "checkboxFacet",
        track_label: label,
        module: "track-click"
    }
  end
end
