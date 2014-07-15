class ResultSetPresenter
  include ApplicationHelper
  include ActionView::Helpers

  attr_reader :finder, :result_count, :documents_noun, :applied_filters, :params, :result_set

  def initialize(finder, facet_params)
    @finder = finder
    @result_count = finder.results.count
    @result_set = finder.results
    @documents_noun = finder.document_noun
    @applied_filters = finder.facets.selected_facets_hash
    @params = facet_params
  end

  def to_hash
    {
      count: result_count,
      pluralised_document_noun: documents_noun.pluralize(result_count),
      applied_filters: describe_filters_in_sentence,
      documents: documents,
    }
  end

  def describe_filters_in_sentence
     selections = finder.facets.with_selected_values.map do |facet|
       "#{facet.preposition} #{facet_values_sentence(facet)}"
     end
     selections.to_sentence
   end

   def documents
     documents = result_set.documents.map do |result|
       SearchResultPresenter.new(result).to_hash
     end
     documents
   end
end
