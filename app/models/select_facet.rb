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
        data_attributes: {
          track_category: "filterClicked",
          track_action: name,
          track_label: allowed_value['label'],
        },
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
      'key' => key,
      'preposition' => preposition,
      'values' => value_fragments,
      'word_connectors' => or_word_connectors
    }
  end

  def has_filters?
    selected_values.any?
  end

  def description
    return nil unless has_filters?

    [
      preposition,
      description_sentence,
    ]
  end

  def close_facet?
    selected_values.empty? && allowed_values.count > 10
  end

  def unselected?
    selected_values.empty?
  end

private

  def description_sentence
    value_fragment_labels.to_sentence(two_words_connector: ' or ', last_word_connector: ' or ')
  end

  def value_fragments
    selected_values.map { |value|
      {
        'label' => value['label'],
        'value' => value['value'],
        'parameter_key' => key, # TODO: I think we can get rid of this
        'key' => key, # TODO: I think we can get rid of this
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
