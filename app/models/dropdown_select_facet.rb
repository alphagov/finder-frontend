class DropdownSelectFacet < FilterableFacet
  attr_writer :value

  def allowed_values
    facet['allowed_values']
  end

  def options
    allowed_values.map do |allowed_value|
      {
        value: allowed_value['value'],
        text: allowed_value['text'],
        selected: selected_value == allowed_value,
      }
    end
  end

  def name
    "Filter by #{facet['name']}"
  end

  def sentence_fragment
    return nil unless selected_value.any?

    {
      'type' => "text",
      'preposition' => preposition,
      'values' => [value_fragment],
    }
  end

private

  def value_fragment
    {
      'label' => selected_value['text'],
      'parameter_key' => key,
    }
  end

  def selected_value
    return {} if @value.nil?

    allowed_values.find { |option|
      @value == option['value']
    } || {}
  end
end
