class Document
  attr_reader :title, :public_timestamp, :is_historic, :government_name,
              :content_purpose_supergroup, :document_type, :organisations, :es_score, :top_result

  def initialize(rummager_document, finder)
    rummager_document = rummager_document.with_indifferent_access
    @title = rummager_document.fetch(:title)
    @link = rummager_document.fetch(:link)
    @description = rummager_document.fetch(:description, nil)
    @public_timestamp = rummager_document.fetch(:public_timestamp, nil)
    @document_type = rummager_document.fetch(:content_store_document_type, nil)
    @organisations = rummager_document.fetch(:organisations, [])
    @content_purpose_supergroup = rummager_document.fetch(:content_purpose_supergroup, nil)
    @is_historic = rummager_document.fetch(:is_historic, false)
    @government_name = rummager_document.fetch(:government_name, nil)
    @es_score = rummager_document.fetch(:es_score, nil)
    @top_result = rummager_document.fetch(:top_result, false)
    @finder = finder
    @rummager_document = rummager_document.slice(*metadata_keys)
  end

  def metadata
    raw_metadata.map(&method(:humanize_metadata_name))
  end

  def show_metadata
    metadata.present? && finder.display_metadata?
  end

  def path
    link.starts_with?("/") ? link : "/#{link}"
  end

  def summary
    truncated_description if description.present? && finder.show_summaries?
  end

  def promoted_summary
    truncated_description if description.present? && promoted
  end

  def promoted
    return false unless finder.links.has_key?("ordered_related_items")

    finder.links["ordered_related_items"].any? { |item| item["base_path"] == path }
  end

private

  attr_reader :link, :rummager_document, :finder, :description

  def truncated_description
    # This truncates the description at the end of the first sentence
    description.gsub(/\.\s[A-Z].*/, '.')
  end

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
    return [] if @content_purpose_supergroup == 'services'

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
      id: key,
      name: key,
      value: value,
      labels: labels,
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
      tag.fetch(finder.display_key_for_metadata_key(key), '')
    else
      tag
    end
  rescue StandardError => error
    GovukError.notify(
      error,
      level: 'debug',
      extra: { url: finder.slug, document: link }
    )
    nil
  end
end
