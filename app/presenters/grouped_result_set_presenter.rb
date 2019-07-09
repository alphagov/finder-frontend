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

    primary_group = {}
    secondary_group = {}

    documents.select! { |d| d[:document][:metadata].present? }
    sorted_documents = sort_by_alphabetical(documents)

    # Without facet filtering return all documents without grouping
    return [{ facet_key: "all_businesses", documents: sorted_documents }] if facet_filters.values.empty?

    # If the document is tagged to all primary facet values, and we are filtering
    # by the primary facet, then add the document to default group to prevent
    # duplication in every primary facet value grouping.
    default_documents, other_documents = sorted_documents.partition do |document|
      filtered_by_primary_facet? && tagged_to_all?(primary_facet_key, document)
    end

    default_group = default_documents.empty? ? [] : [{ facet_key: "all_businesses", facet_name: "All businesses", documents: default_documents }]

    other_documents.each do |item|
      document_metadata = item[:document][:metadata]
      document_metadata.each do |metadata|
        key = metadata[:id]
        next unless key && facet_filters.has_key?(key.to_sym)

        if primary_facet_key == key
          # Group by value for the primary facet
          (metadata[:labels] & facet_filters[primary_facet_key.to_sym]).each do |value|
            populate_group(primary_group, value, facet_label_for(value), item)
          end
        else
          # Group by facet name otherwise
          populate_group(secondary_group, key, metadata[:label], item)
        end
      end
    end

    compact_and_sort(primary_group) + compact_and_sort(secondary_group, true) + default_group
  end

private

  def primary_facet_key
    finder.facets.first.key
  end

  def filtered_by_primary_facet?
    facet_filters.key?(primary_facet_key.to_sym)
  end

  def populate_group(groups, key, label, item)
    groups[key] = empty_facet_group(key, label) unless groups[key]
    groups[key][:documents] << item
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

  def empty_facet_group(key, name)
    { facet_key: key, facet_name: name, documents: [] }
  end

  def facet_label_for(key)
    allowed_values = finder.facets.map(&:allowed_values).flatten
    facet = allowed_values.find { |v| v["value"] == key }
    facet["label"] if facet
  end

  def sort_by_alphabetical(search_results)
    search_results.sort_by { |r| r[:document][:title] }
  end

  def compact_and_sort(group, order_by_facet = false)
    group = group.reject { |_, v| v[:documents].empty? }

    if order_by_facet
      sort_by_facet(group)
    else
      group.values.sort_by { |g| g[:facet_name] }
    end
  end

  def sort_by_facet(group)
    results_with_nils = @finder.filters.map do |filter|
      group[filter.key]
    end

    results_with_nils.compact
  end

  def facet_filters
    @filter_params.symbolize_keys.without(:order, :keywords)
  end
end
