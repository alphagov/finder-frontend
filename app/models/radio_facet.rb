class RadioFacet < FilterableFacet
  def options
    allowed_values.map do |allowed_value|
      {
        value: allowed_value['value'],
        text: allowed_value['label'],
        checked: selected_value == allowed_value,
      }
    end
  end

private

  def selected_value
    allowed_values.find { |option| @value == option['value'] } || default_value
  end

  def default_value
    allowed_values.find { |option| option['default'] } || {}
  end
end
