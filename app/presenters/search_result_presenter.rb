class SearchResultPresenter
  include ActionView::Helpers::SanitizeHelper

  delegate :title,
           :summary,
           :is_historic,
           :show_metadata,
           :government_name,
           :format,
           :es_score,
           to: :document

  def initialize(document:, metadata_presenter_class:, doc_index:, doc_count:, finder_name:, debug_score:, highlight:)
    @document = document
    @metadata = metadata_presenter_class.new(document.metadata).present
    @index = doc_index + 1
    @count = doc_count
    @finder_name = finder_name
    @debug_score = debug_score
    @highlight = highlight
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
          track_action: "#{@finder_name}.#{@index}",
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
    @highlight ? document.truncated_description : summary
  end

  def highlight_text
    I18n.t('finders.most_relevant') if @highlight
  end

  def subtext
    published_text = "<span class='published-by'>#{I18n.t('finders.first_published_during')} #{government_name}</span>" if is_historic
    if @debug_score
      debug_text = "<span class='debug-results debug-results--link'>#{link}</span>"\
                   "<span class='debug-results debug-results--meta'>Score: #{es_score || 'no score (sort by relevance)'}</span>"\
                   "<span class='debug-results debug-results--meta'>Format: #{format}</span>"
    end

    sanitize("#{published_text}#{debug_text}") if published_text || debug_text
  end

  def structure_metadata
    return {} unless show_metadata

    metadata.each_with_object({}) do |meta, component_metadata|
      label = meta[:hide_label] ? "<span class='govuk-visually-hidden'>#{meta[:label]}:</span>" : "#{meta[:label]}:"
      value = meta[:is_date] ? "<time datetime='#{meta[:machine_date]}'>#{meta[:human_date]}</time>" : meta[:value]

      component_metadata[meta[:label]] = sanitize("#{label} #{value}", tags: %w(time span))
    end
  end


  attr_reader :document, :metadata
end
