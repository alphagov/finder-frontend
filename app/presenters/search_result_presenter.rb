class SearchResultPresenter
  delegate :title,
           :summary,
           :is_historic,
           :promoted,
           :promoted_summary,
           :show_metadata,
           :government_name,
           :es_score,
           to: :search_result

  def initialize(search_result)
    @search_result = search_result
  end

  def to_hash
    {
      title: title,
      link: link,
      summary: summary,
      is_historic: is_historic,
      government_name: government_name,
      metadata: metadata,
      promoted: promoted,
      promoted_summary: promoted_summary,
      show_metadata: show_metadata,
      es_score: es_score
    }
  end

  def link
    search_result.path
  end

  def metadata
    raw_metadata.map { |datum|
      case datum.fetch(:type)
      when 'date'
        build_date_metadata(datum)
      when 'text'
        build_text_metadata(datum)
      end
    }
  end

  def build_text_metadata(data)
    {
      id: data[:id],
      label: data.fetch(:name),
      value: data.fetch(:value),
      labels: data[:labels],
      is_text: true,
    }
  end

  def build_date_metadata(data)
    date = Date.parse(data.fetch(:value))
    {
      label: data.fetch(:name),
      is_date: true,
      machine_date: date.iso8601,
      human_date: date.strftime("%-d %B %Y"),
    }
  end

private

  attr_reader :search_result

  def raw_metadata
    search_result.metadata
  end
end
