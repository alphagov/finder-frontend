class Document
  attr_reader :title

  def initialize(attrs, finder)
    attrs = attrs.with_indifferent_access
    @title = attrs.fetch(:title)
    @link = attrs.fetch(:link)

    @attrs = attrs.except(:title, :link)
    @finder = finder
  end

  def metadata
    raw_metadata.map(&method(:humanize_metadata_name))
  end

  def path
    "/#{link}"
  end

  def summary
    description = attrs.fetch(:description, nil)

    # This truncates the description at the end of the first sentence
    description = description.gsub(/\.\s[A-Z].*/, '.') if description.present? && finder.show_summaries?
  end

  def metadata_name_mappings
    finder.metadata.select{ |f| f.short_name != nil }
          .each_with_object({}) { |facet, hash| hash[facet.key] = facet.short_name }
  end

private
  attr_reader :link, :attrs, :finder

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
      name: metadata_label(metadata_hash.fetch(:name))
    )
  end

  def metadata_label(key)
    metadata_name_mappings.fetch(key, key.humanize)
  end
end
