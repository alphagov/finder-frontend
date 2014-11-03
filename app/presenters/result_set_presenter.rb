class ResultSetPresenter
  include ERB::Util

  attr_reader :finder, :documents_noun, :params, :results, :total

  def initialize(finder, facet_params)
    @finder = finder
    @results = finder.results.documents
    @total = finder.results.total
    @documents_noun = finder.document_noun
    @params = facet_params
  end

  def to_hash
    {
      total: total > 1000 ? "1,000+" : total,
      pluralised_document_noun: documents_noun.pluralize(total),
      applied_filters: describe_filters_in_sentence,
      documents: documents,
      any_filters_applied: any_filters_applied?,
    }
  end

  def any_filters_applied?
    finder.facet_sentence_fragments.length > 0 || finder.keywords.present?
  end

  def describe_filters_in_sentence
    [
      keywords_description,
      selected_filter_descriptions
    ].compact.join(' ')
  end

  def keywords_description
    if finder.keywords.present?
      href = link_without_facet_value("keywords", finder.keywords)
      "containing <strong>#{html_escape(finder.keywords)}&nbsp;<a href='#{href}'>×</a></strong>"
    else
      ""
    end
  end

  def selected_filter_descriptions
    finder.facet_sentence_fragments.flat_map { |fragment|
      fragment_description(fragment)
    }.join(' ')
  end

  def fragment_description(fragment)
    [
      fragment.preposition,
      fragment_values_to_s(fragment.values)
    ]
  end

  def fragment_values_to_s(values)
    values.map { |value|
      fragment_to_link(value)
    }.to_sentence(last_word_connector: ' or ')
  end

  def fragment_to_link(value)
    "<strong>#{value.label}&nbsp;<a href='#{link_without_facet_value(value.parameter_key, value.other_params)}'>×</a></strong>"
  end

  def link_without_facet_value(parameter_key, other_params)
    query_string = link_params_without_facet_value(parameter_key, other_params).to_query
    CGI.escapeHTML("?#{query_string}")
  end

  def link_params_without_facet_value(parameter_key, other_params)
    params
      .merge(parameter_key => other_params)
      .reject { |_, v| v.blank? }
  end

  def documents
    results.map do |result|
      SearchResultPresenter.new(result).to_hash
    end
  end
end
