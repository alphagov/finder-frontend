class ResultSetParser
  def initialize(finder)
    @finder = finder
  end

  def parse(response)

    documents = response['results']
      .map { |document| Document.new(document, @finder) }

    ResultSet.new(
      documents,
      response['total'],
      parse_dynamic_facets(response['facets'])
    )
  end

private

  def parse_dynamic_facets(response_facets)
    response_facets.map { |key, facet|
      [key, build_dynamic_facet_options(key, facet)]
    }.to_h
  end

  def build_dynamic_facet_options(key, facet)
    facet['options'].map { |option|
      label_key = @finder.display_key_for_metadata_key(key)
      label = option['value'].fetch(label_key, option['value']['slug'])
      value = option['value']['slug']
      OpenStruct.new(label: label, value: value)
    }
  end
end
