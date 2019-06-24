class SearchResultPresenter
  include ActionView::Helpers::SanitizeHelper

  delegate :title,
           :summary,
           :is_historic,
           :show_metadata,
           :government_name,
           :format,
           :es_score,
           to: :search_result

  def initialize(data = {})
    @search_result = data[:search_result]
    @metadata = data[:metadata]
    @index = data[:doc_index] + 1
    @count = data[:doc_count]
    @finder_name = data[:finder_name]
    @debug_score = data[:debug_score]
    @highlight = data[:highlight]
  end

  def to_hash
    {
      link: {
        text: title,
        path: link,
        description: summary_text,
        data_attributes: {
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

  def link
    search_result.path
  end

  def structure_metadata
    return {} unless show_metadata

    metadata.each_with_object({}) do |meta, component_metadata|
      label = meta[:hide_label] ? "<span class='govuk-visually-hidden'>#{meta[:label]}:</span>" : "#{meta[:label]}:"
      value = meta[:is_date] ? "<time datetime='#{meta[:machine_date]}'>#{meta[:human_date]}</time>" : meta[:value]

      component_metadata[meta[:label]] = sanitize("#{label} #{value}", tags: %w(time span))
    end
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

  def summary_text
    @highlight ? search_result.truncated_description : summary
  end

  def highlight_text
    I18n.t('finders.most_relevant') if @highlight
  end

private

  attr_reader :search_result, :metadata
end
