class SearchResultPresenter
  # Defines how many of the top results to show parts for (if present)
  SHOW_PARTS_FOR_TOP_N_RESULTS = 3

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

  def initialize(document:, rank:, metadata_presenter_class:, doc_count:, facets:, content_item:, debug_score:, result_number:, include_ecommerce: true)
    @document = document
    @rank = rank
    @metadata = metadata_presenter_class.new(document.metadata(facets)).present
    @count = doc_count
    @debug_score = debug_score
    @result_number = result_number
    @content_item = content_item
    @include_ecommerce = include_ecommerce
  end

  def document_list_component_data
    {
      link: {
        text: title,
        path: link,
        description: sanitize(summary_text),
        data_attributes: ga4_ecommerce_data(link).merge(ecommerce_data(link, title)),
      },
      metadata: structure_metadata,
      metadata_raw: metadata,
      subtext:,
      parts: include_parts? ? structure_parts : nil,
    }
  end

private

  class MalformedPartError < StandardError; end

  def link
    document.path
  end

  def summary_text
    document.description if content_item.show_summaries?
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

  def include_parts?
    result_number <= SHOW_PARTS_FOR_TOP_N_RESULTS
  end

  def structure_parts
    structured_parts = parts.map.with_index(1) do |part, index|
      has_required_data = %i[title slug body].all? { |key| part.key? key }
      unless has_required_data
        GovukError.notify(MalformedPartError.new, extra: { part:, link: })
        next
      end
      path = "#{link}/#{part[:slug]}"
      {
        link: {
          text: part[:title],
          path:,
          description: part[:body],
          data_attributes: ga4_ecommerce_data(path).merge(ecommerce_data(path, part[:title], part_index: index)),
        },
      }
    end
    structured_parts.compact
  end

  def ga4_ecommerce_data(path)
    {
      ga4_ecommerce_path: path,
      ga4_ecommerce_content_id: @document.content_id,
      ga4_ecommerce_row: 1,
      ga4_ecommerce_index: document.index,
    }
  end

  def ecommerce_data(link, title, part_index: nil)
    return {} unless @include_ecommerce

    {
      ecommerce_path: link,
      ecommerce_row: 1,
      ecommerce_index: document.index,
      track_category: "navFinderLinkClicked",
      track_action: [content_item.title, document.index, part_index].compact.join("."),
      track_label: link,
      track_options: {
        dimension22: part_index,
        dimension28: @count,
        dimension29: title,
      }.compact,
    }
  end

  attr_reader :document, :metadata, :content_item, :result_number
end
