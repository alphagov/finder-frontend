# typed: true
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

    # TODO: These could live in a finder definition to make this finder-agnostic grouping.
    default_group_name = "all_businesses"
    default_group = empty_facet_group(default_group_name, "All businesses")

    primary_group = {}
    secondary_group = {}

    documents.select! { |d| d[:document][:metadata].present? }
    sorted_documents = sort_by_promoted_alphabetical(documents)

    # With no facet filtering add all documents to default group
    if facet_filters.values.empty?
      default_group.delete(:facet_name) # Remove heading when no other groups exist.
      default_group[:documents] = sorted_documents
    else
      sorted_documents.each do |item|
        document_metadata = item[:document][:metadata]
        # If the document is tagged to all primary facet values, and we are filtering
        # by the primary facet, then add the document to default group to prevent
        # duplication in every primary facet value grouping.
        if filtered_by_primary_facet? && tagged_to_all?(primary_facet_key, document_metadata)
          default_group[:documents] << item
        else
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
      end
    end

    groups = [compact_and_sort(primary_group), compact_and_sort(secondary_group, true)].flatten
    groups << default_group unless default_group[:documents].empty?
    groups
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

  def tagged_to_all?(facet_key, metadata)
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

  def sort_by_promoted(results)
    results.sort_by { |r| r[:document][:promoted] ? 0 : 1 }
  end

  def sort_by_promoted_alphabetical(search_results)
    sorted_results = search_results.sort_by { |r| r[:document][:title] }
    sort_by_promoted(sorted_results)
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
