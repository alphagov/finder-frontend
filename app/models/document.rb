class Document
  attr_reader :title, :public_timestamp, :is_historic, :government_name

  def initialize(attrs, finder)
    attrs = attrs.with_indifferent_access
    @title = attrs.fetch(:title)
    @link = attrs.fetch(:link)
    @description = attrs.fetch(:description, nil)
    @public_timestamp = attrs.fetch(:public_timestamp)
    @is_historic = attrs.fetch(:is_historic, false)
    @government_name = attrs.fetch(:government_name, nil)

    @finder = finder
    @attrs = attrs.slice(*metadata_keys)
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

  def metadata_keys
    date_metadata_keys + tag_metadata_keys
  end

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
      .map { |label| get_metadata_label(key, label) }
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

  def get_metadata_label(key, tag)
    if tag.respond_to? :fetch
      tag.fetch(finder.display_key_for_metadata_key(key))
    else
      tag
    end
  rescue => error
    Airbrake.notify(error)
    nil
  end
end
