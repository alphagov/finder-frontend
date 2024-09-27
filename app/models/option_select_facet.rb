class OptionSelectFacet < FilterableFacet
  attr_reader :value

  def initialize(facet, values)
    @value = Array(values)
    super(facet)
  end

  def options(controls, key)
    # NOTE: We use a symbol-based hash here unlike all our other hash
    # data-structures because we pass this to a govuk_component partial
    # that expects symbol keys, not strings
    @options ||= allowed_values.map do |allowed_value|
      {
        value: allowed_value["value"],
        label: allowed_value["label"],
        id: "#{key}-#{allowed_value['value']}",
        checked: selected_values.include?(allowed_value),
        controls: controls || nil,
      }
    end
  end

  def sentence_fragment
    return nil unless selected_values.any?

    {
      "key" => key,
      "preposition" => preposition,
      "values" => value_fragments,
      "word_connectors" => or_word_connectors,
    }
  end

  def has_filters?
    selected_values.any?
  end

  def applied_filters
    selected_values.map do |value|
      {
        name:,
        label: value["label"],
        query_params: { key => [value["value"]] },
      }
    end
  end

  def unselected?
    selected_values.empty?
  end

  def cacheable?
    unselected? || selected_values.one?
  end

  def cache_key(index_section = nil, index_section_count = nil)
    Digest::SHA256.hexdigest({ name:, ga4_section:, index_section:, index_section_count:, selected: selected_values, allowed: allowed_values }.to_json)
  end

  def query_params
    { key => selected_values.map { |value| value["value"] } }
  end

  def closed_on_load?(option_select_facet_counter)
    return false if open_on_load?

    closed_by_default?(option_select_facet_counter)
  end

  # TODO: open_on_load is currently only used in the Industry facets
  # and we want the industry facet to be closed on load for mobile devices
  # This will likely need refactoring if we decide to keep this approach and
  # use it in other option select facets
  def closed_on_load_mobile?
    open_on_load?
  end

  def ga4_section
    name
  end

private

  def value_fragments
    @value_fragments ||= selected_values.map do |value|
      {
        "label" => value["label"],
        "value" => value["value"],
        "parameter_key" => key,
      }
    end
  end

  def selected_values
    @selected_values ||= begin
      return [] if @value.nil?

      allowed_values.select do |option|
        @value.include?(option["value"])
      end
    end
  end

  def open_on_load?
    facet["open_on_load"] || false
  end

  def closed_by_default?(option_select_facet_counter)
    option_select_facet_counter.positive? && unselected?
  end
end
