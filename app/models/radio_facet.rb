class RadioFacet < Facet
  attr_reader :allowed_values, :include_blank

  def initialize(params = {})
    super
    @include_blank = params[:include_blank]
    @allowed_values = params[:allowed_values]
  end

  def value
    Array(@value).find { |value|
      allowed_values.map(&:value).include?(value)
    }
  end

  def values_for_select
    ([blank_value_for_select] + allowed_values_for_select).compact
  end

  def selected_values
    allowed_values.select { |option| option.value == value && option.described }
  end

  def sentence_fragment
    return nil unless value

    OpenStruct.new(
      preposition: preposition,
      values: [
        OpenStruct.new(
          label: value.capitalize,
          parameter_key: key,
          other_params: nil,
        ),
      ]
    )
  end

private
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
