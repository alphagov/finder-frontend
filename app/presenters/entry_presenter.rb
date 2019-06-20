# typed: true
class EntryPresenter
  delegate :title,
           :summary,
           :path,
           to: :entry

  WEBSITE_ROOT = Plek.current.website_root.gsub(/https?:\/\//, '')

  def initialize(entry)
    @entry = entry
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

  attr_reader :entry
end
