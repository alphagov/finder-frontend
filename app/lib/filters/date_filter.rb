module Filters
  class DateFilter < Filter
  private

    def value
      @value ||= serialized_values.join(",")
    end

    def serialized_values
      present_values.map do |key, date|
        "#{key}:#{date.iso8601}"
      end
    end

    def present_values
      parsed_values.select do |_, date|
        date.present?
      end
    end

    def parsed_values
      user_values.reduce({}) do |values, (key, date_string)|
        values.merge(key => DateParser.new(date_string).parse)
      end
    end

    def user_values
      if params.is_a?(Hash)
        params
      else
        {}
      end
    end
  end
end
