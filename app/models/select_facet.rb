class SelectFacet < FilterableFacet
  attr_reader :allowed_values

  def initialize(facet)
    super
    @allowed_values = facet.allowed_values
  end

  def value
    return [] if @value.blank?

    permitted_values = allowed_values.map(&:value)
    @value.select {|v| permitted_values.include?(v) }
  end

  def value=(new_value)
    @value = Array(new_value)
  end

  def selected_values
    return [] if @value.nil?
    allowed_values.select { |option|
      @value.include?(option.value)
    }
  end

  def sentence_fragment
    return nil unless selected_values.any?

    OpenStruct.new(
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
        other_params: other_params(v),
      )
    }
  end

  def other_params(v)
    selected_values
      .map(&:value)
      .reject { |selected_value|  selected_value == v.value }
  end
end
