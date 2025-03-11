class NestedFacet < FilterableFacet
  attr_accessor :sub_facet_key, :sub_facet_name

  def initialize(facet, value_hash)
    @value_hash = value_hash
    @sub_facet_key = facet["sub_facet_key"]
    @sub_facet_name = facet["sub_facet_name"]

    super(facet)
  end

  alias_method :main_facet_key, :key

  def main_facet_options
    default_selection_options = [{ text: "All #{pluralized_main_facet_short_name}", value: "" }]
    allowed_values.inject(default_selection_options) do |options, allowed_value|
      option = {
        text: allowed_value["label"],
        value: allowed_value["value"],
        selected: @value_hash[key] == allowed_value["value"],
      }
      options << option
    end
  end

  def sub_facets_allowed_values
    allowed_values.pluck("sub_facets").flatten.compact
  end

  def sub_facet_options
    default_selection_options = [{ text: "All #{pluralized_sub_facet_short_name}", value: "" }]

    sub_facets_allowed_values.inject(default_selection_options) do |options, sub_facet_value|
      option = {
        text: facet_text(sub_facet_value),
        value: sub_facet_value["value"],
        selected: @value_hash[sub_facet_key] == sub_facet_value["value"],
      }
      option.merge!(data_attributes: { main_facet_value: sub_facet_value["main_facet_value"], main_facet_label: sub_facet_value["main_facet_label"] })

      options << option
    end
  end

  def applied_filters
    return [] unless has_filters?

    main_facet_filter = {
      name: name,
      label: selected_main_facet_value[:text],
      query_params: {
        main_facet_key => selected_main_facet_value[:value],
        sub_facet_key => selected_sub_facet_value&.fetch(:value),
      }.compact,
    }

    if selected_sub_facet_value
      sub_facet_filter = {
        name: sub_facet_name,
        label: selected_sub_facet_value[:text],
        query_params: { sub_facet_key => selected_sub_facet_value[:value] },
      }
    end

    [main_facet_filter, sub_facet_filter].compact
  end

  def has_filters?
    selected_main_facet_value.present?
  end

  def sentence_fragment
    return nil if selected_main_facet_value.nil?

    {
      "type" => "nested",
      "preposition" => preposition,
      "values" => value_fragments,
      "word_connectors" => and_word_connectors,
    }
  end

  def query_params
    {
      main_facet_key => (selected_main_facet_value || {})[:value],
      sub_facet_key => (selected_sub_facet_value || {})[:value],
    }
  end

private

  def value_fragments
    [
      value_fragment(selected_main_facet_value, key),
      value_fragment(selected_sub_facet_value, sub_facet_key),
    ].compact
  end

  def value_fragment(value, key)
    return nil if value.nil?

    {
      "label" => value[:text],
      "parameter_key" => key,
      "value" => value[:value],
    }
  end

  def selected_main_facet_value
    @selected_main_facet_value ||= main_facet_options.find do |v|
      v[:value] == @value_hash[key]
    end
  end

  def selected_sub_facet_value
    @selected_sub_facet_value ||= sub_facet_options.find do |v|
      v[:value] == @value_hash[sub_facet_key]
    end
  end

  def facet_text(value)
    value["main_facet_label"] ? "#{value['main_facet_label']} - #{value['label']}" : value["label"]
  end

  def pluralized_main_facet_short_name
    (short_name || name).downcase.pluralize
  end

  def pluralized_sub_facet_short_name
    sub_facet_name.downcase.pluralize
  end
end
