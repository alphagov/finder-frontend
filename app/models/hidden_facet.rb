class HiddenFacet < FilterableFacet

  def allowed_values
    facet['allowed_values']
  end

  def sentence_fragment
    return nil unless value
    {
      'type' => 'text',
      'preposition' => preposition,
      'values' => value_fragments
    }
  end

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
