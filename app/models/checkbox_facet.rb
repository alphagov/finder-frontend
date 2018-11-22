class CheckboxFacet < FilterableFacet
  attr_writer :value

  def checkboxes
    @checkboxes ||= facet['checkboxes'].map { |checkbox| Checkbox.new(checkbox) }
  end

  def sentence_fragment
    return nil if selected_checkboxes.empty?

    {
      'type' => "text",
      'preposition' => preposition,
      'values' => value_fragments,
    }
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
        'parameter_key' => key,
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
