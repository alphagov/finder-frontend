class ResultSetPresenter
  include ERB::Util
  include ActionView::Helpers::NumberHelper

  attr_reader :pluralised_document_noun, :debug_score, :start_offset

  delegate :atom_url, to: :content_item

  def initialize(content_item, facets, results, filter_params, sort_presenter, metadata_presenter_class, show_top_result = false, debug_score = false)
    @content_item = content_item
    @facets = facets
    @documents = results.documents
    @total = results.total
    @start_offset = results.start + 1
    @pluralised_document_noun = content_item.document_noun.pluralize(total)
    @filter_params = filter_params
    @sort_presenter = sort_presenter
    @show_top_result = show_top_result
    @metadata_presenter_class = metadata_presenter_class
    @debug_score = debug_score
  end

  def displayed_total
    "#{number_with_delimiter(total)} #{pluralised_document_noun}"
  end

  def total_count
    @total
  end

  def search_results_content
    component_data = document_list_component_data(documents_to_convert: documents)
    {
      document_list_component_data: component_data,
      zero_results: total.zero?,
      page_count: component_data.count,
      finder_name: content_item.title,
      debug_score: debug_score,
    }
  end

  def user_supplied_keywords
    @filter_params.fetch("keywords", "")
  end

  def sort_option
    presenter = sort_presenter.to_hash
    return nil unless presenter

    presenter[:options].find { |o| o[:selected] }
  end

private

  attr_reader :metadata_presenter_class, :sort_presenter, :total, :documents, :facets, :content_item

  def document_list_component_data(documents_to_convert:)
    documents_to_convert.map.with_index do |document, index|
      SearchResultPresenter.new(document: document,
                                rank: index + 1,
                                metadata_presenter_class: metadata_presenter_class,
                                doc_count: documents.count,
                                facets: facets,
                                content_item: content_item,
                                debug_score: debug_score).document_list_component_data
    end
  end

  def best_bet?
    # We found the average score on the top 500 searches and found that 7 was the most suitable number
    if documents[0].es_score && documents[1].es_score
      (documents[0].es_score / documents[1].es_score) > 7
    end
  end

  def unpresented_sort_option
    sort_presenter.selected_option || {}
  end
end
