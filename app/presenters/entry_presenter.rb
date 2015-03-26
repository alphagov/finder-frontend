class EntryPresenter

  delegate :title,
           :summary,
           :path,
           to: :entry

  def initialize(entry)
    @entry = entry
  end

  def tag(schema)
    "tag:#{website_root},#{schema_date(schema)}:#{entry.path}"
  end

  def updated_at
    DateTime.parse(entry.public_timestamp)
  end

private
  attr_reader :entry

  def website_root
    Plek.current.website_root.gsub(/https?:\/\//, '')
  end

  def schema_date(schema)
    schema.instance_variable_get(:@feed_options)[:schema_date]
  end

end
