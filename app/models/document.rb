class Document
  attr_reader :title, :public_timestamp, :is_historic, :government_name

  def initialize(rummager_document, finder)
    rummager_document = rummager_document.with_indifferent_access
    @title = rummager_document.fetch(:title)
    @link = rummager_document.fetch(:link)
    @description = rummager_document.fetch(:description, nil)
    @public_timestamp = rummager_document.fetch(:public_timestamp, nil)
    @is_historic = rummager_document.fetch(:is_historic, false)
    @government_name = rummager_document.fetch(:government_name, nil)

    @finder = finder
    @rummager_document = rummager_document.slice(*metadata_keys)
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

  attr_reader :link, :rummager_document, :finder, :description

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
      value: rummager_document[key],
      type: "date",
    }
  end

  def tag_metadata
    tag_metadata_keys
      .map(&method(:build_tag_metadata))
      .select(&method(:metadata_value_present?))
  end

  def tag_labels_for(key)
    Array(rummager_document.fetch(key, []))
      .map { |label| get_metadata_label(key, label) }
      .select(&:present?)
  end

  def build_tag_metadata(key)
    labels = tag_labels_for(key)

    value = if labels.count > 1
              "#{labels.first} and #{labels.count - 1} others"
            else
              labels.first
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
    GovukError.notify(
      error,
      level: 'debug',
      extra: { url: finder.slug, document: link }
    )
    nil
  end
end
