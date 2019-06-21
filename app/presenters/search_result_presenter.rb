class SearchResultPresenter
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

    if show_metadata
      metadata.each_with_object({}) do |meta, component_metadata|
        label = meta[:hide_label] ? "<span class='govuk-visually-hidden'>#{meta[:label]}:</span>" : "#{meta[:label]}:"

        if meta[:is_date]
          value = "<time datetime='#{meta[:machine_date]}'>#{meta[:human_date]}</time>"
        else
          value = meta[:value]
        end

        component_metadata[meta[:label]] = "#{label} #{value}".html_safe
      end
    end
  end

  def subtext
    published_text = "<span class='published-by'>First published during the #{government_name}</span>" if is_historic
    debug_text = "<span class='debug-results debug-results--link'>#{link}</span>"\
                 "<span class='debug-results debug-results--meta'>Score: #{es_score || "no score (sort by relevance)"}</span>"\
                 "<span class='debug-results debug-results--meta'>Format: #{format}</span>" if @debug_score
    "#{published_text}#{debug_text}".html_safe if published_text || debug_text
  end

  def summary_text
    @highlight ? search_result.truncated_description : summary
  end

  def highlight_text
    "Most relevant result" if @highlight
  end

private

  attr_reader :search_result, :metadata
end
