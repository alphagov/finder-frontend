class RadioFacet < Facet
  attr_reader :allowed_values, :include_blank

  def initialize(params = {})
    super
    @include_blank = params[:include_blank]
    @allowed_values = params[:allowed_values]
  end

  def value
    @value if allowed_values.map(&:value).include?(@value)
  end

  def values_for_select
    ([blank_value_for_select] + allowed_values_for_select).compact
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
