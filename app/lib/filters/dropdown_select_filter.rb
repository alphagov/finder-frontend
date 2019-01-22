module Filters
  class DropdownSelectFilter < Filter
    def value
      Array(parsed_value)
    end

  private

    def parsed_value
      return unless params.present?

      JSON.parse params
    rescue JSON::ParserError
      params
    end
  end
end
