class AbstractDocument
  attr_reader :title

  def self.date_metadata_keys
    []
  end

  def self.tag_metadata_keys
    []
  end

  def self.metadata_keys
    tag_metadata_keys + date_metadata_keys
  end

  def self.metadata_name_mappings
    {}
  end

  def initialize(attrs)
    @title = attrs.fetch(:title)
    @link = attrs.fetch(:link)

    @attrs = attrs.except(:title, :link)
  end

  def metadata
    raw_metadata.map(&method(:humanize_metadata_name))
  end

  def path
    "/#{link}"
  end

  def summary
    nil
  end

private
  attr_reader :link, :attrs

  def raw_metadata
    tag_metadata + date_metadata
  end

  def date_metadata
    self.class.date_metadata_keys
      .map(&method(:build_date_metadata))
      .select(&method(:metadata_value_present?))
  end

  def build_date_metadata(key)
    {
      name: key,
      value: attrs[key],
      type: "date",
    }
  end

  def tag_metadata
    self.class.tag_metadata_keys
      .map(&method(:build_tag_metadata))
      .select(&method(:metadata_value_present?))
  end

  def tag_labels_for(key)
    Array(attrs.fetch(key, []))
      .map { |tag| tag.fetch("label") }
     .select(&:present?)
  end

  def build_tag_metadata(key)
    labels = tag_labels_for(key)

    if labels.count > 1
      value = "#{labels.first} and #{labels.count - 1} others"
    else
      value = labels.first
    end

    {
      name: key,
      value: value,
      type: "text",
    }
  end

  def metadata_value_present?(metadata_hash)
    metadata_hash.fetch(:value).present?
  end

  def humanize_metadata_name(metadata_hash)
    metadata_hash.merge(
      name: metadata_label(metadata_hash.fetch(:name))
    )
  end

  def metadata_label(key)
    self.class.metadata_name_mappings.fetch(key, key.humanize)
  end

  def truncated_summary_or_nil
    description = attrs.fetch(:description, nil)
    description = description.truncate(60, separator: '.') if description.present?
    description
  end
end
