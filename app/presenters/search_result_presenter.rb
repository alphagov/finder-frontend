class SearchResultPresenter
  include ActionView::Helpers::SanitizeHelper

  delegate :title,
           :parts,
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
      },
      metadata: structure_metadata,
      metadata_raw: metadata,
      subtext: subtext,
      parts: structure_parts,
    }
  end

private

  class MalformedPartError < StandardError; end

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
      next if meta[:is_date] && format == "recommended-link"

      value = meta[:is_date] ? "<time datetime='#{meta[:machine_date]}'>#{meta[:human_date]}</time>" : meta[:value]
      component_metadata[meta[:label]] = sanitize("#{meta[:label]}: #{value}", tags: %w[time span])
    end
  end

  def structure_parts
    structured_parts = parts.map.with_index(1) do |part, _index|
      has_required_data = %i[title slug body].all? { |key| part.key? key }
      unless has_required_data
        GovukError.notify(MalformedPartError.new, extra: { part: part, link: link })
        next
      end
      {
        link: {
          text: part[:title],
          path: "#{link}/#{part[:slug]}",
          description: part[:body],
        },
      }
    end
    structured_parts.compact
  end

  attr_reader :document, :metadata, :content_item
end
