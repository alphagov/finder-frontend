class SelectFacet < FilterableFacet
  delegate :allowed_values, to: :facet

  def options
    allowed_values.map do |allowed_value|
      {
        value: allowed_value.value,
        label: allowed_value.label,
        id: allowed_value.value,
        checked: selected_values.include?(allowed_value),
      }
    end
  end

  def value=(new_value)
    @value = Array(new_value)
  end

  def sentence_fragment
    return nil unless selected_values.any?

    OpenStruct.new(
      type: "text",
      preposition: preposition,
      values: value_fragments,
    )
  end

private

  def value_fragments
    selected_values.map { |v|
      OpenStruct.new(
        label: v.label,
        parameter_key: key,
      )
    }
  end

  def selected_values
    return [] if @value.nil?
    allowed_values.select { |option|
      @value.include?(option.value)
    }
  end
end
