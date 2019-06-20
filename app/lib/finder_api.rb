# typed: true
# Facade that speaks to rummager. Combines a content item with
# search results from rummager.
class FinderApi
  attr_reader :content_item

  def initialize(content_item, filter_params, override_sort_for_feed: false)
    @content_item = content_item
    @filter_params = filter_params
    @override_sort_for_feed = override_sort_for_feed
    @order =
      if override_sort_for_feed
        'most-recent'
      else
        filter_params['order']
      end
  end

  def search_results
    @search_results ||= fetch_search_response(content_item)
  end

  def content_item_with_search_results
    augment_content_item_with_results
    content_item
  end

private

  attr_reader :filter_params, :override_sort_for_feed

  def merge_and_deduplicate(search_response)
    results = search_response.fetch("results")

    return results[0] if results.count == 1

    # This currently doesn't handle more complex features such as pagination.
    # The only finder where the facets work as an OR filter
    # doesn't use pagination and there aren't enough documents it to be
    # important. The results are sorted here because they are only
    # sorted by Rummager within the results of each query.

    all_unique_results = results
      .flat_map { |hash| hash["results"] }
      .uniq { |hash| hash["_id"] }
    {
      "results" => sort_batch_results(all_unique_results),
      "total" => all_unique_results.count,
      "start" => 0,
    }
  end

  def sort_batch_results(raw_results)
    case @order
    when 'most-viewed'
      raw_results.sort_by { |hash| hash['popularity'] }.reverse
    when 'most-recent'
      raw_results.sort_by { |hash| hash['public_timestamp'] }.reverse
    when 'a-to-z'
      raw_results.sort_by { |hash| hash['title'] }
    else
      sort_by_relevance(raw_results)
    end
  end

  def sort_by_relevance(raw_results)
    return raw_results unless relevance_scores_exist?(raw_results)

    raw_results.sort_by { |hash| hash['es_score'] }.reverse
  end

  def relevance_scores_exist?(results)
    results.all? { |result| result['es_score'].present? }
  end

  def fetch_search_response(content_item)
    queries = query_builder_class.new(
      finder_content_item: content_item,
      params: filter_params,
      override_sort_for_feed: override_sort_for_feed,
    ).call

    if queries.one?
      GovukStatsd.time("rummager.finder_search") do
        Services.rummager.search(queries.first).to_hash
      end
    else
      GovukStatsd.time("rummager.finder_batch_search") do
        merge_and_deduplicate(
          Services.rummager.batch_search(queries).to_hash
        )
      end
    end
  end

  def augment_content_item_with_results
    augment_facets_with_dynamic_values(content_item)
  end

  def augment_facets_with_dynamic_values(content_item_hash)
    facets = content_item_hash['details']['facets']
    return unless facets.present?

    # for each facet in the content item
    # if it's in the registry, let's use that
    # otherwise, get it from the search result
    facets.select { |facet| facet['allowed_values'].blank? }
      .each do |facet|
        facet_key = facet["key"]
        if registries.all.has_key?(facet_key)
          facet['allowed_values'] = allowed_values_from_registry(facet_key)
        elsif (facet_details = search_results.dig("facets", facet_key))
          facet['allowed_values'] = allowed_values_for_facet_details(facet_key, facet_details)
        end
      end
  end

  def allowed_values_for_facet_details(facet_key, facet_details)
    facet_details.fetch("options", {})
      .map { |f| f.fetch("value", {}) }
      .map { |value| present_facet_option(value, facet_key) }
      .reject { |f| f["label"].blank? || f["value"].blank? }
  end

  def allowed_values_from_registry(facet_key)
    registries.all[facet_key].values
      .map { |_, results| present_facet_option(results, facet_key) }
      .reject { |f| f["label"].blank? || f["value"].blank? }
  end

  def present_facet_option(value, facet_key)
    slug = value.fetch("slug", "")
    title = value.fetch("title", find_facet_title_by_slug(slug, facet_key))
    label = generate_label(value, title)

    {
      "label" => label,
      "value" => slug,
    }
  end

  def generate_label(value, title)
    acronym = value.fetch("acronym", "")
    return title if acronym.blank? || acronym == title

    title + " (" + acronym + ")"
  end

  def find_facet_title_by_slug(slug, facet_key)
    registry = registries.all[facet_key]
    return "" if registry.nil?

    item = registry[slug] || {}
    item.fetch("title", "")
  end

  def query_builder_class
    SearchQueryBuilder
  end

  def registries
    @registries ||= Registries::BaseRegistries.new
  end
end
