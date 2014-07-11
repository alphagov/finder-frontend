class ResultSetPresenter
  include ActionView::Helpers::UrlHelper
  attr_reader :result_count, :documents_noun, :applied_filters, :params, :result_set

  def initialize(finder, facet_params)
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
      applied_filters: describe_filters_in_sentence(applied_filters),
      documents: documents,
    }
  end

  def describe_filters_in_sentence(facets)
     selections = facets.map do |facet|
       "#{facet[:preposition]} #{facet_values_sentence(facet)}"
     end
     selections.to_sentence
   end

  def facet_values_sentence(facet)
    values = facet[:selected_values_hash].map do |option|

      # build a link with out this facet selected
      # make a content tag
      # url_for(link_params_without_facet_value(facet.key, option.value))
      link_url = link_params_without_facet_value(facet[:key], option[:value])
      #content_tag(:strong, "#{option[:label]} #{link_to("×", link_url)}".html_safe)

      content_tag(:strong, option[:label].html_safe)
    end
    values.to_sentence(last_word_connector: ' and ')
  end

  def link_params_without_facet_value(key, value)
     new_params = params.dup
     if new_params[key].is_a? Array
       new_params[key] = new_params[key] - [value]
       new_params.delete(key) if new_params[key].empty?
     else
       new_params.delete(key)
     end
     new_params
   end

   def documents
     documents = result_set.documents.map do |result|
       SearchResultPresenter.new(result).to_hash
     end
     documents
   end
end
