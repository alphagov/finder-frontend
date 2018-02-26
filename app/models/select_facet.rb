class SelectFacet < FilterableFacet
  def allowed_values
    facet['allowed_values']
  end

  def options
    # NOTE: We use a symbol-based hash here unlike all our other hash
    # data-structures because we pass this to a govuk_component partial
    # that expects symbol keys, not strings
    allowed_values_map = allowed_values.map do |allowed_value|
      # When documents are tagged to a non-existing thing (person, org)
      # the label will be blank. Filter them out here to avoid a weird UI.
      next if allowed_value['label'].blank?

      {
        value: allowed_value['value'],
        label: allowed_value['label'],
        id: allowed_value['value'],
        checked: selected_values.include?(allowed_value),
      }
    end

    allowed_values_map.compact
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
