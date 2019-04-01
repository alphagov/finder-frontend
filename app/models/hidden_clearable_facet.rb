class HiddenClearableFacet < FilterableFacet
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

private

  def value_fragments
    @value_fragments ||= selected_values.map { |value|
      {
          'label' => value['label'],
          'value' => value['value'],
          'parameter_key' => key
      }
    }
  end

  def selected_values
    @selected_values ||= begin
      return [] if @value.nil?

      allowed_values.select { |option|
        @value.include?(option['value'])
      }
    end
  end
end
