class DateFacet < Facet
  def value
    serialized_values.join(",")
  end

private
  def serialized_values
    present_values.map { |key, date|
      "#{key}:#{date.to_iso8601}"
    }
  end

  def present_values
    parsed_values.select { |_, date|
      date.date.present?
    }
  end

  def parsed_values
    (@value || {}).reduce({}) { |h, (k, v)|
      h.merge(k => safe_date_parse(v))
    }
  end

  def safe_date_parse(date_string)
    DateInput.new(date_string) rescue nil
  end

  class DateInput
    attr_reader :original_input, :date

    def initialize(date_string)
      @original_input = date_string
    end

    def to_iso8601
      date.iso8601
    end

    def date
      @date ||= Date.parse(original_input) rescue nil
    end

    def to_param
      original_input
    end
  end
end
