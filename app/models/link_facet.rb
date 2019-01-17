class LinkFacet < FilterableFacet
  attr_writer :value

  def allowed_values
    facet['allowed_values']
  end

  def options
    allowed_values.map do |allowed_value|
      {
        label: allowed_value['label'],
        link: allowed_value['link']
      }
    end
  end

  def name
    facet['name']
  end

  def has_filters?
    false
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
      'label' => selected_value['label'],
      'parameter_key' => key,
    }
  end

  def selected_value
    return {} if @value.nil?

    allowed_values.find { |option|
      @value == option['link']
    } || {}
  end
end
