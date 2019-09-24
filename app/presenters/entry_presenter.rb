class EntryPresenter
  delegate :title,
           :path,
           to: :entry

  WEBSITE_ROOT = Plek.current.website_root.gsub(/https?:\/\//, "")

  def initialize(entry, show_summaries)
    @entry = entry
    @show_summaries = show_summaries
  end

  def summary
    @entry.truncated_description if show_summaries
  end

  def tag(schema)
    "tag:#{WEBSITE_ROOT},#{self.class.schema_date(schema)}:#{entry.path}"
  end

  def updated_at
    Time.zone.parse(entry.public_timestamp || entry.release_timestamp)
  end

  def self.feed_ended_id(schema, base_path)
    "tag:#{WEBSITE_ROOT},#{schema_date(schema)}:#{base_path}/feed-ended"
  end

  def self.schema_date(schema)
    schema.instance_variable_get(:@feed_options)[:schema_date]
  end

private

  attr_reader :entry, :show_summaries
end
