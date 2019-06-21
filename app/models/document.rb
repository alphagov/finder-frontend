class Document
  attr_reader :title, :public_timestamp, :is_historic, :government_name,
              :content_purpose_supergroup, :document_type, :organisations,
              :release_timestamp, :es_score, :format

  def initialize(rummager_document, finder)
    rummager_document = rummager_document.with_indifferent_access
    @title = rummager_document.fetch(:title)
    @link = rummager_document.fetch(:link)
    @description = rummager_document.fetch(:description, nil)
    @public_timestamp = rummager_document.fetch(:public_timestamp, nil)
    @release_timestamp = rummager_document.fetch(:release_timestamp, nil)
    @document_type = rummager_document.fetch(:content_store_document_type, nil)
    @organisations = rummager_document.fetch(:organisations, [])
    @content_purpose_supergroup = rummager_document.fetch(:content_purpose_supergroup, nil)
    @is_historic = rummager_document.fetch(:is_historic, false)
    @government_name = rummager_document.fetch(:government_name, nil)
    @es_score = rummager_document.fetch(:es_score, nil)
    @format = rummager_document.fetch(:format, nil)
    @finder = finder
    @facet_content_ids = rummager_document.fetch(:facet_values, [])
    @rummager_document = rummager_document.slice(*metadata_keys)
  end

  def metadata
    raw_metadata.map(&method(:humanize_metadata_name)) + link_metadata
  end

  def show_metadata
    metadata.present? && finder.display_metadata?
  end

  def path
    link
  end

  def summary
    truncated_description if description.present? && finder.show_summaries?
  end

  def truncated_description
    # This truncates the description at the end of the first sentence
    description.gsub(/\.\s[A-Z].*/, '.') if description.present?
  end

private

  attr_reader :link, :rummager_document, :finder, :facet_content_ids, :description

  def is_mainstream_content?
    %w(completed_transaction
       local_transaction
       calculator
       smart_answer
       simple_smart_answer
       place
       licence
       step_by_step
       transaction
       answer
       guide).include?(@document_type)
  end

  def metadata_keys
    date_metadata_keys + tag_metadata_keys
  end

  def date_metadata_keys
    finder.date_metadata_keys
  end

  def tag_metadata_keys
    keys = finder.text_metadata_keys
    keys.reject do |key|
      key == 'organisations' && is_mainstream_content?
    end
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

  def link_metadata
    return [] if facet_content_ids.empty?

    facet_content_ids
      .group_by(&method(:facet_details_for_content_id))
      .map do |k, v|
        labels = map_content_ids_to_values(v)
        k.merge(
          labels: labels,
          value: format_value(labels)
        )
      end
  end

  def facet_details_for_content_id(content_id)
    finder.facet_details_lookup[content_id]
  end

  def map_content_ids_to_values(content_ids)
    content_ids.map { |id| finder.facet_value_lookup[id] }
  end

  def tag_labels_for(key)
    Array(rummager_document.fetch(key, []))
      .map { |label| get_metadata_label(key, label) }
      .select(&:present?)
  end

  def build_tag_metadata(key)
    labels = tag_labels_for(key)
    value = format_value(labels)

    {
      id: key,
      name: key,
      value: value,
      labels: labels,
      type: "text",
    }
  end

  def format_value(labels)
    if labels.count > 1
      "#{labels.first} and #{labels.count - 1} others"
    else
      labels.first
    end
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
  rescue StandardError => e
    GovukError.notify(
      e,
      level: 'debug',
      extra: { url: finder.slug, document: link }
    )
    nil
  end
end
