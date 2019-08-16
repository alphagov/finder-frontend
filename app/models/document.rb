class Document
  attr_reader :title, :public_timestamp, :is_historic, :government_name,
              :content_purpose_supergroup, :document_type, :organisations,
              :release_timestamp, :es_score, :format, :content_id, :index,
              :facet_content_ids, :description

  def initialize(document_hash, finder, index)
    document_hash = document_hash.with_indifferent_access
    @title = document_hash.fetch(:title)
    @link = document_hash.fetch(:link)
    @content_id = document_hash.fetch(:content_id, nil)
    @description = document_hash.fetch(:description, nil)
    @public_timestamp = document_hash.fetch(:public_timestamp, nil)
    @release_timestamp = document_hash.fetch(:release_timestamp, nil)
    @document_type = document_hash.fetch(:content_store_document_type, nil)
    @organisations = document_hash.fetch(:organisations, [])
    @content_purpose_supergroup = document_hash.fetch(:content_purpose_supergroup, nil)
    @is_historic = document_hash.fetch(:is_historic, false)
    @government_name = document_hash.fetch(:government_name, nil)
    @es_score = document_hash.fetch(:es_score, nil)
    @format = document_hash.fetch(:format, nil)
    @finder = finder
    @facet_content_ids = document_hash.fetch(:facet_values, [])
    @document_hash = document_hash
    @index = index
  end

  def metadata
    raw_metadata.map(&method(:humanize_metadata_name))
  end

  def path
    link
  end

  def truncated_description
    # This truncates the description at the end of the first sentence
    description.gsub(/\.\s[A-Z].*/, '.') if description.present?
  end

private

  attr_reader :link, :document_hash, :finder

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
      value: document_hash[key],
      type: "date",
    }
  end

  def tag_metadata
    tag_metadata_keys
      .map(&method(:build_tag_metadata))
      .select(&method(:metadata_value_present?))
  end

  def tag_labels_for(key)
    Array(document_hash.fetch(key, []))
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
