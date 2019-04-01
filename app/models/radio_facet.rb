class RadioFacet < FilterableFacet
  def value
    @value || default_value['value']
  end

  def options
    allowed_values.map do |allowed_value|
      {
        value: allowed_value['value'],
        text: allowed_value['label'],
        checked: selected_value == allowed_value,
      }
    end
  end

  def has_filters?
    selected_value.present?
  end

  def sentence_fragment
    return nil if hide_facet_tag?
  end

  def has_value?
    @value.present?
  end

private

  def selected_value
    allowed_values.find { |option| @value == option['value'] } || default_value
  end

  def default_value
    @default_value ||= allowed_values.find { |option| option['default'] } || {}
  end
end
