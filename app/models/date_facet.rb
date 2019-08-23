class DateFacet < FilterableFacet
  attr_reader :value

  def initialize(facet, value_hash)
    @value = value_hash || {}
    super(facet)
  end

  def user_supplied_from_date
    @value['from']
  end

  def user_supplied_to_date
    @value['to']
  end

  def sentence_fragment
    return nil unless has_filters?

    {
      'key' => key,
      'preposition' => [preposition, additional_preposition].compact.join(' '),
      'values' => value_fragments,
      'word_connectors' => and_word_connectors
    }
  end

  def has_filters?
    present_values.any?
  end

  def query_params
    {
      key => @value
    }
  end

private

  def value_fragments
    present_values.map { |name, date|
      {
        'label' => date.date.strftime("%e %B %Y"),
        'parameter_key' => key,
        'value' => date.original_input,
        'name' => "#{key}[#{name}]"
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
