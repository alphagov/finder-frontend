class Document
  attr_reader :title, :last_update

  def initialize(attrs, finder)
    attrs = attrs.with_indifferent_access
    @title = attrs.fetch(:title)
    @link = attrs.fetch(:link)
    @description = attrs.fetch(:description, nil)
    @last_update = attrs.fetch(:last_update)

    @attrs = attrs.except(:title, :link, :description, :last_update)
    @finder = finder
  end

  def metadata
    raw_metadata.map(&method(:humanize_metadata_name))
  end

  def path
    link.starts_with?("/") ? link : "/#{link}"
  end

  def summary
    if finder.show_summaries? && description.present?
      # This truncates the description at the end of the first sentence
      description.gsub(/\.\s[A-Z].*/, '.')
    end
  end

private
  attr_reader :link, :attrs, :finder, :description

  def date_metadata_keys
    finder.date_metadata_keys
  end

  def tag_metadata_keys
    finder.text_metadata_keys
  end

  def raw_metadata
    tag_metadata + date_metadata
  end

  def date_metadata
    date_metadata_keys
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
    tag_metadata_keys
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
      name: finder.label_for_metadata_key(metadata_hash.fetch(:name))
    )
  end
end
