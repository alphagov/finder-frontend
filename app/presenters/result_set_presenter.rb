class ResultSetPresenter
  include ERB::Util
  include ActionView::Helpers::NumberHelper

  attr_reader :pluralised_document_noun, :debug_score, :start_offset, :include_ecommerce

  delegate :atom_url, to: :content_item

  def initialize(content_item, facets, results, filter_params, sort_presenter, metadata_presenter_class, debug_score: false, include_ecommerce: true)
    @content_item = content_item
    @facets = facets
    @documents = results.documents
    @total = results.total
    @start_offset = results.start + 1
    @pluralised_document_noun = content_item.document_noun.pluralize(total)
    @filter_params = filter_params
    @sort_presenter = sort_presenter
    @metadata_presenter_class = metadata_presenter_class
    @debug_score = debug_score
    @include_ecommerce = include_ecommerce
  end

  def displayed_total
    # TODO: to be displayed for all finders pending content + design review. See: https://trello.com/c/8sSaeXS4/2085-apply-results-heading-text-change-to-all-finders
    if content_item.document_noun == "licence"
      return I18n.t("finders.search_result_presenter.heading_text",
                    prefix: "Results: ",
                    total: number_with_delimiter(total),
                    document_noun: pluralised_document_noun)
    end

    I18n.t("finders.search_result_presenter.heading_text",
           prefix: nil, total: number_with_delimiter(total), document_noun: pluralised_document_noun).strip
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
      debug_score:,
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

  def has_sort_options
    sort_presenter.to_hash.blank? ? true : false
  end

private

  attr_reader :metadata_presenter_class, :sort_presenter, :total, :documents, :facets, :content_item

  def document_list_component_data(documents_to_convert:)
    documents_to_convert.map.with_index do |document, index|
      SearchResultPresenter.new(
        document:,
        rank: index + 1,
        result_number: start_offset + index,
        metadata_presenter_class:,
        doc_count: documents.count,
        facets:,
        content_item:,
        debug_score:,
        include_ecommerce:,
      ).document_list_component_data
    end
  end
end
