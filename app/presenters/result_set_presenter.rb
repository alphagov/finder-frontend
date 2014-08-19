class ResultSetPresenter

  attr_reader :finder, :documents_noun, :params, :result_set

  def initialize(finder, facet_params)
    @finder = finder
    @result_set = finder.results
    @documents_noun = finder.document_noun
    @params = facet_params
  end

  def to_hash
    {
      count: result_set.count,
      pluralised_document_noun: documents_noun.pluralize(result_set.count),
      applied_filters: describe_filters_in_sentence,
      documents: documents,
      any_filters_applied: any_filters_applied?,
    }
  end

  def any_filters_applied?
    finder.facets.with_selected_values.count > 0
  end

  def describe_filters_in_sentence
    selections = finder.facets.with_selected_values.map do |facet|
      "#{facet.preposition} #{facet_values_sentence(facet)}"
    end
    selections.to_sentence
  end

  def facet_values_sentence(facet)
    values = facet.selected_values.map do |option|
      query_string = link_params_without_facet_value(facet.key, option.value).to_query
      href = CGI.escapeHTML("?#{query_string}")
      "<strong>#{option.label}&nbsp;<a href='#{href}'>×</a></strong>"
    end
    values.to_sentence(last_word_connector: ' and ')
  end

  def link_params_without_facet_value(facet_key, value_to_remove)
    remaining_values = Array(params.fetch(facet_key)).reject { |facet_value|
      facet_value == value_to_remove
    }

    if remaining_values.empty?
      params.except(facet_key)
    else
      params.except(facet_key).merge(facet_key => remaining_values)
    end
  end

  def documents
    result_set.documents.map do |result|
      SearchResultPresenter.new(result).to_hash
    end
  end
end
