class RadioFacet < FilterableFacet
  def allowed_values
    facet['allowed_values']
  end

  def options
    allowed_values.map do |allowed_value|
      {
        value: allowed_value['value'],
        text: allowed_value['text'],
        checked: selected_value == allowed_value,
      }
    end
  end

  def name
    facet['name']
  end

private

  def selected_value
    return default_value if @value.nil?

    allowed_values.find { |option|
      @value == option['value']
    } || {}
  end

  def default_value
    allowed_values.find { |option| option['default'] } || {}
  end
end
