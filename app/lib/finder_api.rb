# Facade that speaks to the content store and rummager. Returns a content
# item for the finder combined with the actual search results from rummager.
class FinderApi
  def initialize(base_path, filter_params)
    @base_path = base_path
    @filter_params = filter_params
    @order = filter_params['order']
  end

  def content_item
    @content_item ||= fetch_content_item
  end

  def content_item_with_search_results
    search_response = fetch_search_response(content_item)
    augment_content_item_with_results(content_item, search_response)
  end

private

  attr_reader :base_path, :filter_params

  def fetch_content_item
    if development_env_finder_json
      JSON.parse(File.read(development_env_finder_json))
    else
      Services.cached_content_item(base_path)
    end
  end

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
    ).call

    GovukStatsd.time("rummager.finder_batch_search") do
      merge_and_deduplicate(
        Services.rummager.batch_search(queries).to_hash
      )
    end
  end

  def augment_content_item_with_results(content_item, search_response)
    content_item = augment_content_item_details_with_results(content_item, search_response)
    augment_facets_with_dynamic_values(content_item, search_response)
    content_item
  end

  def augment_content_item_details_with_results(content_item, search_response)
    content_item['details']['results'] = search_response.fetch("results")
    content_item['details']['total_result_count'] = search_response.fetch("total")

    content_item['details']['pagination'] = build_pagination(
      content_item['details']['default_documents_per_page'],
      search_response.fetch('start'),
      search_response.fetch('total')
    )

    content_item
  end

  def augment_facets_with_dynamic_values(content_item, search_response)
    search_response.fetch("facets", {}).each do |facet_key, facet_details|
      facet = content_item['details']['facets'].find { |f| f['key'] == facet_key }

      if registries.all.has_key?(facet_key) && facet
        facet['allowed_values'] = allowed_values_from_registry(facet_key)
      elsif facet
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
    label = value.fetch("title", find_facet_title_by_slug(slug, facet_key))

    {
      "label" => label,
      "value" => slug,
    }
  end

  def find_facet_title_by_slug(slug, facet_key)
    registry = registries.all[facet_key]
    return "" if registry.nil?

    item = registry[slug] || {}
    item.fetch("title", "")
  end

  def build_pagination(documents_per_page, start_offset, total_results)
    if documents_per_page
      {
        'current_page' => (start_offset / documents_per_page) + 1,
        'total_pages' => (total_results / documents_per_page.to_f).ceil,
      }
    end
  end

  def query_builder_class
    SearchQueryBuilder
  end

  # Add a finder with the base path as a key and the finder name
  # without filetype as the value; example:
  # "/guidance-and-regulation" => "guidance_and_regulation"
  FINDERS_IN_DEVELOPMENT = {
    "/search/policy-papers-and-consultations" => 'policy_and_engagement',
    "/search/policy-papers-and-consultations/email-signup" => 'policy_and_engagement_email_signup',
    "/search/statistics" => "statistics"
  }.freeze

  def development_env_finder_json
    return development_json if is_development_json?

    ENV["DEVELOPMENT_FINDER_JSON"]
  end

  def development_json
    "features/fixtures/#{FINDERS_IN_DEVELOPMENT[base_path]}.json"
  end

  def is_development_json?
    base_path.present? && FINDERS_IN_DEVELOPMENT[base_path].present?
  end

  def registries
    @registries ||= Registries::BaseRegistries.new
  end
end
