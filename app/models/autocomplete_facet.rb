class AutocompleteFacet < OptionSelectFacet
  def to_partial_path
    "autocomplete_facet"
  end

  def options
    allowed_values.map { |allowed_value| [allowed_value['label'], allowed_value['value']] }
  end

  def data_attributes
    {
      track_category: "filterClicked",
      track_action: key
    }
  end

  def selected_option
    return nil unless selected_values.any?

    selected_values.first.values
  end
end
