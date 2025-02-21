class NestedFacet < OptionSelectFacet
  def facet_options
    allowed_values.inject([{ text: "All #{pluralized_facet_short_name}" }]) do |options, allowed_value|
      options << { text: allowed_value["label"], value: allowed_value["value"] }
    end
  end

private

  def pluralized_facet_short_name
    short_name&.downcase&.pluralize || name&.downcase&.pluralize
  end
end
