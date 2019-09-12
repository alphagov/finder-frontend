class TopicalFacet < OptionSelectFacet
  def allowed_values
    [facet["open_value"], facet["closed_value"]]
  end

  def to_partial_path
    "option_select_facet"
  end
end
