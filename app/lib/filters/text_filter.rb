module Filters
  class TextFilter < Filter
    def value
      Array(parsed_value)
    end

  private

    def parsed_value
      return if params.blank?

      if multi_value?
        option_lookup.select { |key, _| params.include? key }.values.flatten
      else
        params
      end
    end

    def multi_value?
      facet.has_key?('option_lookup')
    end

    def option_lookup
      @option_lookup ||= facet['option_lookup']
    end
  end
end
