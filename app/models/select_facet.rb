class SelectFacet < Facet
  attr_reader :allowed_values, :include_blank

  def self.from_hash(select_facet_hash)
    self.new(
      facet_attrs_from_hash(select_facet_hash).merge({
        include_blank: select_facet_hash['include_blank'],
        allowed_values: select_facet_hash['allowed_values'].map do | allowed_value_hash |
          build_allowed_value(allowed_value_hash.symbolize_keys)
        end
      })
    )
  end

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
  def self.build_allowed_value(attrs)
    OpenStruct.new(label: attrs[:label], value: attrs[:value])
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
