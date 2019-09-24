class MetadataPresenter
  def initialize(raw_metadata)
    @raw_metadata = raw_metadata
  end

  def present
    raw_metadata.map { |datum|
      case datum.fetch(:type)
      when "date"
        build_date_metadata(datum)
      when "text", "content_id"
        build_text_metadata(datum)
      end
    }
  end

private

  attr_reader :raw_metadata

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
end
