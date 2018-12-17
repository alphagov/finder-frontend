class SelectFacet < FilterableFacet
  def allowed_values
    facet['allowed_values']
  end

  def options
    [["", ""]] + allowed_values.map { |allowed_value| [allowed_value['label'], allowed_value['value']] }
  end

  def data_attributes
    {
      track_category: "filterClicked",
      track_action: key
    }
  end

  def value=(new_value)
    @value = Array(new_value)
  end

  def sentence_fragment
    return nil unless selected_values.any?

    {
      'key' => key,
      'preposition' => preposition,
      'values' => value_fragments,
      'word_connectors' => or_word_connectors
    }
  end

  def has_filters?
    selected_values.any?
  end

  def close_facet?
    selected_values.empty? && allowed_values.count > 10
  end

  def selected_option
    return nil unless selected_values.any?
    selected_values.first.values
  end

private

  def value_fragments
    selected_values.map { |value|
      {
        'label' => value['label'],
        'value' => value['value'],
        'parameter_key' => key
      }
    }
  end

  def selected_values
    return [] if @value.nil?

    allowed_values.select { |option|
      @value.include?(option['value'])
    }
  end
end
