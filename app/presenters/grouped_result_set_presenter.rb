class GroupedResultSetPresenter < ResultSetPresenter
  def search_results_content
    super.merge(
      grouped_document_list_component_data: grouped_document_list_component_data,
      display_grouped_results: grouped_display?,
    )
  end

private

  def grouped_document_list_component_data
    grouped_documents.map do |name_documents_hash|
      group_name = name_documents_hash[:group_name]
      documents = name_documents_hash[:documents]
      document_hashes = document_list_component_data(documents_to_convert: documents)
      {
        group_name: group_name,
        documents: document_hashes,
      }.compact
    end
  end

  def grouped_display?
    @grouped_display ||= begin
      sorts_by_topic = sort_option.dig("key") == "topic"
      @filter_params[:order] == "topic" || (!@filter_params.has_key?(:order) && sorts_by_topic)
    end
  end

  def linked_facet_data(document)
    document.facet_content_ids
      .group_by { |content_id| facet_for_content_id(content_id) }
      .map do |facet, content_ids|
      labels = content_ids.map { |content_id| value_for_content_id(content_id) }
      {
        key: facet.key,
        name: facet.short_name || facet.name,
        labels: labels,
      }
    end
  end

  def facet_for_content_id(content_id)
    facet_by_allowed_value_lookup_hash[content_id]
  end

  def facet_by_allowed_value_lookup_hash
    @facet_by_allowed_value_lookup_hash ||= begin
      finder_presenter.facets.each_with_object({}) do |facet, result|
        facet.allowed_values.each do |allowed_value|
          result[allowed_value["content_id"]] = facet
        end
      end
    end
  end

  def value_for_content_id(content_id)
    facet_value_lookup_hash[content_id]
  end

  def facet_value_lookup_hash
    @facet_value_lookup_hash ||= begin
      all_allowed_values = finder_presenter.facets.flat_map(&:allowed_values)
      all_allowed_values.to_h do |val|
        [val["content_id"], val["value"]]
      end
    end
  end

  def grouped_documents
    return [] unless grouped_display?

    documents_with_facet_data = documents.reject { |document| document.facet_content_ids.empty? }
    sorted_documents = sort_by_alphabetical(documents_with_facet_data)

    # Without facet filtering return all documents without grouping
    return [{ documents: sorted_documents }] if facet_filters.values.empty?

    # If the document is tagged to all primary facet values, and we are filtering
    # by the primary facet, then add the document to default group to prevent
    # duplication in every primary facet value grouping.
    default_documents, other_documents = sorted_documents.partition do |document|
      selected_values_in_primary_facet.present? && tagged_to_all_primary_facet_values?(document)
    end

    default_group = [{ group_name: "All businesses",
                       documents: default_documents }]

    unsorted_primary_group = selected_values_in_primary_facet.map do |selected_value|
      primary_documents = documents_tagged_to_primary_facet_value(other_documents, selected_value)
      {
        group_name: label_for_facet_value(selected_value),
        documents: primary_documents,
      }
    end

    primary_group = unsorted_primary_group.sort_by { |group| group[:group_name] }

    secondary_group = secondary_facets.map do |secondary_facet|
      secondary_documents = documents_tagged_to_secondary_facet(other_documents, secondary_facet.key)
      {
        group_name: label_from_metadata(secondary_documents.first, secondary_facet.key),
        documents: secondary_documents,
      }
    end

    (primary_group + secondary_group + default_group).reject { |result| result[:documents].empty? }
  end

  def label_from_metadata(document, key)
    return if document.nil?

    datum = linked_facet_data(document).find { |d| d[:key] == key }
    datum[:name]
  end

  def documents_tagged_to_primary_facet_value(documents, selected_value)
    documents.select do |document|
      linked_facet_data(document).any? do |datum|
        datum[:key] == primary_facet_key &&
          datum[:labels].include?(selected_value)
      end
    end
  end

  def documents_tagged_to_secondary_facet(documents, secondary_group_name)
    documents.select do |document|
      linked_facet_data(document).any? { |datum| datum[:key] == secondary_group_name }
    end
  end

  def primary_facet
    finder_presenter.facets.first
  end

  def primary_facet_key
    primary_facet.key
  end

  def selected_values_in_primary_facet
    facet_filters[primary_facet_key.to_sym] || []
  end

  def tagged_to_all_primary_facet_values?(document)
    document_facet_data = linked_facet_data(document)
    facet_datum = document_facet_data.find { |m| m[:key] == primary_facet_key }
    return false unless primary_facet && facet_datum

    allowed_values = primary_facet.allowed_values.map { |v| v["value"] }
    facet_datum[:labels].to_set.superset? allowed_values.to_set
  end

  def label_for_facet_value(key)
    allowed_values = finder_presenter.facets.flat_map(&:allowed_values)
    allowed_value = allowed_values.find(-> { {} }) { |v| v["value"] == key }
    allowed_value.fetch("label", "")
  end

  def sort_by_alphabetical(documents)
    documents.sort_by(&:title)
  end

  def secondary_facets
    finder_presenter.filters[1..-1].select { |f| facet_filters.keys.include?(f.key.to_sym) }
  end

  def facet_filters
    @filter_params.symbolize_keys.without(:order, :keywords)
  end
end
