class DateFacet < FilterableFacet
  def sentence_fragment
    return nil unless present_values.any?

    {
      'type' => "date",
      'preposition' => [preposition, additional_preposition].compact.join(' '),
      'values' => value_fragments,
    }
  end

private

  def value_fragments
    present_values.map { |_, date|
      {
        'label' => date.date.strftime("%e %B %Y"),
        'parameter_key' => key,
      }
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

  def additional_preposition
    if present_values.length == 2
      "between"
    else
      present_values.map { |k, _|
        preposition_mappings[k]
      }.first
    end
  end

  def preposition_mappings
    {
      "from" => "after",
      "to" => "before",
    }.with_indifferent_access
  end

  class DateInput
    attr_reader :original_input

    def initialize(date_string)
      @original_input = date_string
    end

    def to_iso8601
      date.iso8601
    end

    def date
      @date ||= DateParser.parse(original_input)
    end

    def to_param
      original_input
    end
  end
end
