class DateFacet < FilterableFacet
  attr_reader :date_values

  def initialize(facet, value_hash)
    @date_values = value_hash || {}
    super(facet)
  end

  def parsed_from_date
    parsed_values["from"]
  end

  def parsed_to_date
    parsed_values["to"]
  end

  def error_message_to(search_query)
    if search_query.invalid?
      search_query.errors[:to_date].first
    end
  end

  def error_message_from(search_query)
    if search_query.invalid?
      search_query.errors[:from_date].first
    end
  end

  def sentence_fragment
    return nil unless has_filters?

    {
      "key" => key,
      "preposition" => [preposition, additional_preposition].compact.join(" "),
      "values" => value_fragments,
      "word_connectors" => and_word_connectors,
    }
  end

  def applied_filters
    present_values.map do |type, date|
      preposition = preposition_mappings[type]
      {
        name: "#{name} #{preposition}",
        label: date.date.strftime("%e %B %Y"),
        query_params: { key => { type => date.original_input } },
      }
    end
  end

  def has_filters?
    present_values.any?
  end

  def query_params
    { key => date_values }
  end

  def ga4_section
    name
  end

private

  def value_fragments
    present_values.map do |name, date|
      {
        "label" => date.date.strftime("%e %B %Y"),
        "parameter_key" => key,
        "value" => date.original_input,
        "name" => "#{key}[#{name}]",
      }
    end
  end

  def present_values
    parsed_values.select do |_, date|
      date.date.present?
    end
  end

  def parsed_values
    date_values.transform_values { |value| DateInput.new(value) }
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
end
