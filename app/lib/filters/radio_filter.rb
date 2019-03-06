module Filters
  class RadioFilter < Filter
    def value
      Array(parsed_value)
    end

  private

    def parsed_value
      return if params.blank?

      JSON.parse params
    rescue JSON::ParserError
      params
    end
  end
end
