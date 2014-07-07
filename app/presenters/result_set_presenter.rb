class ResultSetPresenter
  include ActionView::Helpers::UrlHelper
  attr_reader :result_count, :results, :documents_noun, :applied_filters, :params

  def initialize(finder, facet_params)
    @result_count = finder.results.count
    @results = finder.results.search_results_hash
    @documents_noun = finder.document_noun
    @applied_filters = finder.selected_facets_hash
    @params = facet_params
  end

  def to_hash
    {
      count: result_count,
      pluralised_document_noun: documents_noun.pluralize(result_count),
      applied_filters: describe_filters_in_sentence(applied_filters),
      documents: format_result_metadata(results),
    }
  end

  def describe_filters_in_sentence(facets)
     selections = facets.map do |facet|
       "#{facet[:preposition]} #{facet_values_sentence(facet)}"
     end
     selections.to_sentence
   end

  def facet_values_sentence(facet)
    values = facet[:selected_values].map do |option|

      # build a link with out this facet selected
      # make a content tag
      # url_for(link_params_without_facet_value(facet.key, option.value))
      link_url = link_params_without_facet_value(facet[:key], option[:value])
      #content_tag(:strong, "#{option[:label]} #{link_to("×", link_url)}".html_safe)

      content_tag(:strong, option[:label].html_safe)
    end
    values.to_sentence(last_word_connector: ' and ')
  end

  def format_result_metadata(results)
    results = results.map do |result|
      {title: result[:title], slug: result[:slug], metadata: format_result_metadata1(result[:metadata])}
    end
    results
  end
  def format_result_metadata1(result_metadata)
    data = result_metadata.map do |datum|
      { name: datum[:name], value: format_date_if_date(datum[:value], datum[:type]) }
    end
    data
  end
  def  format_date_if_date(value, type)
    case type
    when "date"
      Date.parse(value).strftime("%d %B %Y")
    else
      value
    end
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

end
