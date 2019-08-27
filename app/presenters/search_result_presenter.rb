class SearchResultPresenter
  include ActionView::Helpers::SanitizeHelper

  delegate :title,
           :is_historic,
           :government_name,
           :format,
           :es_score,
           to: :document

  def initialize(document:, metadata_presenter_class:, doc_count:, facets:, content_item:, debug_score:, highlight:)
    @document = document
    @metadata = metadata_presenter_class.new(document.metadata(facets)).present
    @count = doc_count
    @debug_score = debug_score
    @highlight = highlight
    @content_item = content_item
  end

  def document_list_component_data
    {
      link: {
        text: title,
        path: link,
        description: summary_text,
        data_attributes: {
          ecommerce_path: link,
          ecommerce_content_id: document.content_id,
          ecommerce_row: 1,
          track_category: "navFinderLinkClicked",
          track_action: "#{content_item.title}.#{document.index}",
          track_label: link,
          track_options: {
            dimension28: @count,
            dimension29: title
          }
        }
      },
      metadata: structure_metadata,
      metadata_raw: metadata,
      subtext: subtext,
      highlight: @highlight,
      highlight_text: highlight_text
    }
  end

private

  def link
    document.path
  end

  def summary_text
    document.truncated_description if @highlight || content_item.show_summaries?
  end

  def highlight_text
    I18n.t('finders.search_result_presenter.most_relevant') if @highlight
  end

  def subtext
    published_text = "<span class='published-by'>#{I18n.t('finders.search_result_presenter.first_published_during')} #{government_name}</span>" if is_historic
    if @debug_score
      debug_text = "<span class='debug-results debug-results--link'>#{link}</span>"\
                   "<span class='debug-results debug-results--meta'>Score: #{es_score || 'no score (sort by relevance)'}</span>"\
                   "<span class='debug-results debug-results--meta'>Format: #{format}</span>"
    end

    sanitize("#{published_text}#{debug_text}") if published_text || debug_text
  end

  def structure_metadata
    return {} if content_item.eu_exit_finder?

    metadata.each_with_object({}) do |meta, component_metadata|
      value = meta[:is_date] ? "<time datetime='#{meta[:machine_date]}'>#{meta[:human_date]}</time>" : meta[:value]
      component_metadata[meta[:label]] = sanitize("#{meta[:label]}: #{value}", tags: %w(time span))
    end
  end


  attr_reader :document, :metadata, :content_item
end
