class SelectFacet < FilterableFacet
  def allowed_values
    facet['allowed_values']
  end

  def options
    # NOTE: We use a symbol-based hash here unlike all our other hash
    # data-structures because we pass this to a govuk_component partial
    # that expects symbol keys, not strings
    allowed_values.map do |allowed_value|
      {
        value: allowed_value['value'],
        label: allowed_value['label'],
        id: allowed_value['value'],
        checked: selected_values.include?(allowed_value),
      }
    end
  end

  def value=(new_value)
    @value = Array(new_value)
  end

  def sentence_fragment
    return nil unless selected_values.any?

    {
      'type' => "text",
      'preposition' => preposition,
      'values' => value_fragments,
    }
  end

  def close_facet?
    allowed_values.count > 10
  end

private

  def value_fragments
    selected_values.map { |v|
      {
        'label' => v['label'],
        'parameter_key' => key,
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
