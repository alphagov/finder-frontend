class CheckboxFacet < FilterableFacet
  attr_writer :value

  def checkboxes
    @checkboxes ||= facet['checkboxes'].map { |checkbox| Checkbox.new(checkbox) }
  end

  def sentence_fragment
    return nil unless has_filters?

    {
      'key' => key,
      'preposition' => preposition,
      'values' => value_fragments,
      'word_connectors' => and_word_connectors
    }
  end

  def has_filters?
    selected_checkboxes.any?
  end

  def value
    facet['value']
  end

  def checked?(checkbox)
    @value && @value.include?(checkbox.value)
  end

private

  def value_fragments
    selected_checkboxes.map { |checkbox|
      {
        'label' => checkbox.label,
        'parameter_key' => key, # TODO I think we can get rid of this
        'value' => checkbox.value
      }
    }
  end

  def selected_checkboxes
    return [] unless @value && @value.any?

    checkboxes.select { |checkbox|
      @value.include?(checkbox.value)
    }
  end
end
