class SelectFacet < Facet
  attr_reader :allowed_values, :include_blank

  def initialize(params = {})
    super
    @include_blank = params[:include_blank]
    @allowed_values = params[:allowed_values]
  end

  def value
    return nil if @value.nil?

    permitted_values = allowed_values.map(&:value)
    @value.select {|v| permitted_values.include?(v) }
  end

  def values_for_select
    ([blank_value_for_select] + allowed_values_for_select).compact
  end

  def selected_values
    return [] if @value.nil?
    allowed_values.select { |option| @value.include?(option.value) && option.described }
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

  def allowed_values_for_select
    allowed_values.map(&:to_option_for_select)
    allowed_values.map do |option|
      [option.label, option.value]
    end
  end

  def blank_value_for_select
    [@include_blank, nil] if @include_blank.present?
  end
end
