class SearchResultPresenter

  attr_reader :title, :link, :raw_metadata, :summary

  def initialize(search_result)
    @title = search_result.title
    @link = search_result.link
    @summary = search_result.summary

    @raw_metadata = search_result.metadata
  end

  def to_hash
    {
      title: title,
      link: link,
      summary: summary,
      metadata: metadata,
    }
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
      label: data.fetch(:name),
      value: data.fetch(:value),
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
end
