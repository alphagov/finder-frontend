class Document
  attr_reader :title,
              :public_timestamp,
              :is_historic,
              :government_name,
              :content_purpose_supergroup,
              :document_type,
              :organisations,
              :release_timestamp,
              :es_score,
              :format,
              :content_id,
              :index,
              :description,
              :score,
              :original_rank,
              :parts

  def initialize(document_hash, index)
    document_hash = document_hash.with_indifferent_access
    @title = document_hash.fetch(:title)
    @link = document_hash.fetch(:link)
    @content_id = document_hash.fetch(:content_id, nil)
    @description = document_hash.fetch(:description_with_highlighting, nil)
    @public_timestamp = document_hash.fetch(:public_timestamp, nil)
    @release_timestamp = document_hash.fetch(:release_timestamp, nil)
    @document_type = document_hash.fetch(:content_store_document_type, nil)
    @organisations = document_hash.fetch(:organisations, [])
    @content_purpose_supergroup = document_hash.fetch(:content_purpose_supergroup, nil)
    @is_historic = document_hash.fetch(:is_historic, false)
    @government_name = document_hash.fetch(:government_name, nil)
    @es_score = document_hash.fetch(:es_score, nil)
    @score = document_hash.fetch(:combined_score, nil) || @es_score
    @original_rank = document_hash.fetch(:original_rank, nil)
    @format = document_hash.fetch(:format, nil)
    @document_hash = document_hash
    @parts = document_hash.fetch(:parts, [])
    @index = index
  end

  def metadata(facets)
    all_metadata(facets).map { |metadata| humanize_metadata_name(facets, metadata) }
  end

  def path
    link
  end

private

  attr_reader :link, :document_hash

  def is_mainstream_content?
    %w[completed_transaction
       local_transaction
       calculator
       smart_answer
       simple_smart_answer
       place
       licence
       step_by_step
       transaction
       answer
       guide].include?(@document_type)
  end

  def date_metadata_keys(facets)
    metadata_facets(facets).select { |f| f.type == "date" }.map(&:key)
  end

  def text_metadata_facets(facets)
    facets = metadata_facets(facets).select { |f| f.type == "text" }
    facets.reject do |facet|
      facet.key == "organisations" && is_mainstream_content?
    end
  end

  def metadata_facets(facets)
    facets.select(&:metadata?)
  end

  def all_metadata(facets)
    text_metadata(facets) + date_metadata(facets)
  end

  def date_metadata(facets)
    return [] if @content_purpose_supergroup == "services"

    date_metadata_keys(facets)
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

  def text_metadata(facets)
    metadata_labels = {}
    text_metadata_facets(facets).each do |facet|
      document_values = document_hash[facet.key]
      next if document_values.nil?

      metadata_labels[facet.key] = if facet.allowed_values.empty?
                                     metadata_labels_from_document_values(document_values, facet.key)
                                   else
                                     metadata_labels_from_allowed_values(facet.allowed_values, document_values, facet.key)
                                   end
    end
    metadata_labels.map(&method(:build_text_metadata)).select(&method(:metadata_value_present?))
  end

  def build_text_metadata(facet_key, values)
    {
      id: facet_key,
      name: facet_key,
      value: format_value(values),
      labels: values,
      type: "text",
    }
  end

  def metadata_labels_from_document_values(document_values, facet_key)
    if document_values.is_a?(Array)
      document_values.map { |document_value| get_metadata_label(facet_key, document_value) }
    else
      [get_metadata_label(facet_key, document_values)]
    end
  end

  def metadata_labels_from_allowed_values(allowed_values, document_values, facet_key)
    document_values = [document_values] unless document_values.is_a?(Array)
    document_values.map do |document_value|
      document_value_key = document_value.is_a?(Hash) ? document_value["value"] : document_value
      matched_value = allowed_values.find { |allowed_value| allowed_value["value"] == document_value_key }
      matched_value ? matched_value["label"] : get_metadata_label(facet_key, document_value)
    end
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

  def humanize_metadata_name(facets, metadata_hash)
    metadata_hash.merge(
      name: label_for_metadata_key(facets, metadata_hash.fetch(:name)),
    )
  end

  def label_for_metadata_key(facets, key)
    facet = metadata_facets(facets).find { |f| f.key == key }

    if format == "oim_project"
      facet.short_name || facet.name
    else
      facet.short_name || facet.key.humanize
    end
  end

  def get_metadata_label(key, tag)
    if tag.respond_to? :fetch
      tag.fetch(display_key_for_metadata_key(key), "")
    else
      tag
    end
  end

  def display_key_for_metadata_key(key)
    if %w[organisations document_collections].include?(key)
      "title"
    else
      "label"
    end
  end
end
