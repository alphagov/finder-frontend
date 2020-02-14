class SearchResultPresenter
  include ActionView::Helpers::SanitizeHelper

  delegate :title,
           :is_historic,
           :government_name,
           :format,
           :score,
           :es_score,
           :original_rank,
           to: :document

  def initialize(document:, rank:, metadata_presenter_class:, doc_count:, facets:, content_item:, debug_score:)
    @document = document
    @rank = rank
    @metadata = metadata_presenter_class.new(document.metadata(facets)).present
    @count = doc_count
    @debug_score = debug_score
    @content_item = content_item
  end

  def document_list_component_data
    {
      link: {
        text: title,
        path: link,
        description: sanitize(summary_text),
        data_attributes: {
          ecommerce_path: link,
          ecommerce_row: 1,
          track_category: "navFinderLinkClicked",
          track_action: "#{content_item.title}.#{document.index}",
          track_label: link,
          track_options: {
            dimension28: @count,
            dimension29: title,
          },
        },
      },
      metadata: structure_metadata,
      metadata_raw: metadata,
      subtext: subtext,
    }
  end

private

  def link
    document.path
  end

  def summary_text
    document.truncated_description if content_item.show_summaries?
  end

  def subtext
    published_text = "<span class='published-by'>#{I18n.t('finders.search_result_presenter.first_published_during')} #{government_name}</span>" if is_historic
    if @debug_score
      debug_text = "<span class='debug-results debug-results--link'>#{link}</span>"
      debug_text += if score
                      "<span class='debug-results debug-results--meta'>Score: #{score} (ranked ##{@rank})</span>"
                    else
                      "<span class='debug-results debug-results--meta'>Ranked: ##{@rank}</span>"
                    end
      debug_text += "<span class='debug-results debug-results--meta'>Original score: #{es_score} (ranked ##{original_rank})</span>" if es_score && original_rank
      debug_text += "<span class='debug-results debug-results--meta'>Format: #{format}</span>"
    end

    sanitize("#{published_text}#{debug_text}") if published_text || debug_text
  end

  def structure_metadata
    metadata.each_with_object({}) do |meta, component_metadata|
      value = meta[:is_date] ? "<time datetime='#{meta[:machine_date]}'>#{meta[:human_date]}</time>" : meta[:value]
      component_metadata[meta[:label]] = sanitize("#{meta[:label]}: #{value}", tags: %w(time span))
    end
  end

  attr_reader :document, :metadata, :content_item
end
