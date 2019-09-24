module Filters
  class DateFilter < Filter
  private

    def value
      @value ||= serialized_values.join(",")
    end

    def serialized_values
      present_values.map { |key, date|
        "#{key}:#{date.iso8601}"
      }
    end

    def present_values
      parsed_values.select { |_, date|
        date.present?
      }
    end

    def parsed_values
      user_values.reduce({}) { |values, (key, date_string)|
        values.merge(key => DateParser.parse(date_string))
      }
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
