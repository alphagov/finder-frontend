module Filters
  class DropdownSelectFilter < Filter
  private

    def value
      @value ||= Array(parsed_value)
    end

    def parsed_value
      return if params.blank?

      JSON.parse params
    rescue JSON::ParserError
      params
    end
  end
end
