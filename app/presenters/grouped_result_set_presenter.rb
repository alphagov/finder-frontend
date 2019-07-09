class GroupedResultSetPresenter < ResultSetPresenter
  def search_results_content
    super.merge(
      grouped_documents: grouped_documents,
      display_grouped_results: grouped_display?
    )
  end

  def grouped_display?
    sorts_by_topic = sort_option.dig('key') == 'topic'
    @filter_params[:order] == "topic" || (!@filter_params.has_key?(:order) && sorts_by_topic)
  end

  def grouped_documents
    return [] unless grouped_display?

    documents_with_metadata = documents.select { |document| document[:document][:metadata].present? }
    sorted_documents = sort_by_alphabetical(documents_with_metadata)

    # Without facet filtering return all documents without grouping
    return [{ documents: sorted_documents }] if facet_filters.values.empty?

    # If the document is tagged to all primary facet values, and we are filtering
    # by the primary facet, then add the document to default group to prevent
    # duplication in every primary facet value grouping.
    default_documents, other_documents = sorted_documents.partition do |document|
      selected_values_in_primary_facet.present? && tagged_to_all?(primary_facet_key, document)
    end

    default_group = [{ group_name: "All businesses", documents: default_documents }]

    unsorted_primary_group = selected_values_in_primary_facet.map do |selected_value|
      documents = documents_tagged_to_primary_facet_value(other_documents, selected_value)
      {
        group_name: label_for_facet_value(selected_value),
        documents: documents
      }
    end

    primary_group = unsorted_primary_group.sort_by { |group| group[:group_name] }

    secondary_group = secondary_facets.map do |secondary_facet|
      documents = documents_tagged_to_secondary_facet(other_documents, secondary_facet.key)
      {
        group_name: label_from_metadata(documents.first, secondary_facet.key),
        documents: documents
      }
    end

    results = primary_group + secondary_group + default_group
    results.reject { |result| result[:documents].empty? }
  end

private

  def label_from_metadata(document, key)
    return if document.nil?

    metadata = document[:document][:metadata].find { |m| m[:id] == key }
    metadata[:label]
  end

  def documents_tagged_to_primary_facet_value(documents, selected_value)
    documents.select do |document|
      document[:document][:metadata].any? do |metadata|
        metadata[:id] == primary_facet_key &&
          metadata[:labels].include?(selected_value)
      end
    end
  end

  def documents_tagged_to_secondary_facet(documents, secondary_group_name)
    documents.select do |document|
      document[:document][:metadata].any? { |metadata| metadata[:id] == secondary_group_name }
    end
  end

  def primary_facet_key
    finder.facets.first.key
  end

  def selected_values_in_primary_facet
    facet_filters[primary_facet_key.to_sym] || []
  end

  def tagged_to_all?(facet_key, document)
    metadata = document.dig(:document, :metadata)
    return false unless metadata

    facet = finder.facets.find { |f| f.key == facet_key }
    facet_metadata = metadata.find { |m| m[:id] == facet_key }
    return false unless facet && facet_metadata

    values = facet.allowed_values.map { |v| v['value'] }
    values & facet_metadata[:labels] == values
  end

  def label_for_facet_value(key)
    allowed_values = finder.facets.flat_map(&:allowed_values)
    allowed_value = allowed_values.find(-> { {} }) { |v| v["value"] == key }
    allowed_value.fetch("label", '')
  end

  def sort_by_alphabetical(search_results)
    search_results.sort_by { |r| r[:document][:title] }
  end

  def secondary_facets
    finder.facets.filters[1..-1].select { |f| facet_filters.keys.include?(f.key.to_sym) }
  end

  def facet_filters
    @filter_params.symbolize_keys.without(:order, :keywords)
  end
end
