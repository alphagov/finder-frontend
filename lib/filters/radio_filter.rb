module Filters
  class RadioFilter < Filter
  private

    def value
      @value ||= if !acceptable_param?
                   default_value
                 elsif multi_value?
                   option_lookup_values(params)
                 else
                   Array(params)
                 end
    end

    def default_value
      return [] if default_allowed_value.blank?

      return option_lookup_values(default_allowed_value) if multi_value?

      Array(default_allowed_value)
    end

    def option_lookup_values(val)
      option_lookup.select { |key, _| val.include? key }.values.flatten
    end

    def default_allowed_value
      @default_allowed_value ||= facet["allowed_values"].find(Proc.new { {} }) { |option| option["default"] }
      @default_allowed_value["value"]
    end

    def acceptable_param?
      params.present? && params.is_a?(String) && param_is_part_of_allowed_values
    end

    def param_is_part_of_allowed_values
      facet["allowed_values"].any? { |option| option["value"] == params }
    end
  end
end
