class ResultSetPresenter
  include ERB::Util
  include ActionView::Helpers::NumberHelper

  attr_reader :pluralised_document_noun, :debug_score, :start_offset

  delegate :atom_url, to: :finder_presenter

  def initialize(finder_presenter, results, filter_params, sort_presenter, metadata_presenter_class, show_top_result = false, debug_score = false)
    @finder_presenter = finder_presenter
    @documents = results.documents
    @total = results.total
    @start_offset = results.start + 1
    @pluralised_document_noun = finder_presenter.document_noun.pluralize(total)
    @filter_params = filter_params
    @sort_presenter = sort_presenter
    @show_top_result = show_top_result
    @metadata_presenter_class = metadata_presenter_class
    @debug_score = debug_score
  end

  def displayed_total
    "#{number_with_delimiter(total)} #{pluralised_document_noun}"
  end

  def search_results_content
    component_data = document_list_component_data(documents_to_convert: documents)
    {
      document_list_component_data: component_data,
      zero_results: total.zero?,
      page_count: component_data.count,
      finder_name: finder_presenter.name,
      debug_score: debug_score,
    }
  end

  def highlight_top_result?
    @show_top_result &&
      finder_presenter.eu_exit_finder? &&
      documents.length >= 2 &&
      sort_option.dig("key").eql?("-relevance") &&
      best_bet?
  end

  def user_supplied_keywords
    @filter_params.fetch("keywords", "")
  end

private

  attr_reader :metadata_presenter_class, :sort_presenter, :total, :finder_presenter, :documents

  def document_list_component_data(documents_to_convert:)
    documents_to_convert.map do |document|
      SearchResultPresenter.new(document: document,
                                metadata_presenter_class: metadata_presenter_class,
                                doc_count: documents.count,
                                facets: finder_presenter.facets,
                                content_item: finder_presenter.content_item,
                                debug_score: debug_score,
                                highlight: highlight(document.index)).document_list_component_data
    end
  end

  def highlight(index)
    index === 1 && highlight_top_result?
  end

  def best_bet?
    # We found the average score on the top 500 searches and found that 7 was the most suitable number
    if documents[0].es_score && documents[1].es_score
      (documents[0].es_score / documents[1].es_score) > 7
    end
  end

  def sort_option
    sort_presenter.selected_option || {}
  end
end
