class NestedFacet < OptionSelectFacet
  attr_accessor :sub_facet_key

  def initialize(facet, values)
    @sub_facet_key = facet["sub_facet_key"]
    super
  end

  def facet_options
    default_selection_options = [{ text: "All #{pluralized_facet_short_name}", value: "" }]
    allowed_values.inject(default_selection_options) do |options, allowed_value|
      option = { text: allowed_value["label"], value: allowed_value["value"] }
      option.merge!(data_attributes: { main_facet_value: allowed_value["main_facet_value"] }) unless is_main_facet?
      options << option
    end
  end

  def is_main_facet?
    sub_facet_key.present?
  end

private

  def pluralized_facet_short_name
    (short_name || name).downcase.pluralize
  end
end
