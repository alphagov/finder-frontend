# Facade that speaks to the content store and rummager. Returns a content
# item for the finder combined with the actual search results from rummager.
class FinderApi
  def initialize(base_path, filter_params)
    @base_path = base_path
    @filter_params = filter_params
  end

  def content_item
    @content_item ||= fetch_content_item
  end

  def content_item_with_search_results
    search_response = fetch_search_response(content_item)
    augment_content_item_with_results(content_item, search_response)
  end

  private

  BASE_PATHS = %w(
    /government/publications/allocation-of-ecmt-haulage-permits-guidance-for-hauliers
    /government/publications/aviation-safety-if-theres-no-brexit-deal
    /government/publications/aviation-security-if-theres-no-brexit-deal
    /government/publications/banking-insurance-and-other-financial-services-if-theres-no-brexit-deal
    /government/publications/breeding-animals-if-theres-no-brexit-deal
    /government/publications/broadcasting-and-video-on-demand-if-theres-no-brexit-deal
    /government/publications/citizens-rights-uk-and-irish-nationals-in-the-common-travel-area
    /government/publications/commercial-road-haulage-in-the-eu-if-theres-no-brexit-deal
    /government/publications/consumer-rights-if-theres-no-brexit-deal--2
    /government/publications/data-protection-if-theres-no-brexit-deal
    /government/publications/driving-in-the-eu-if-theres-no-brexit-deal
    /government/publications/erasmus-in-the-uk-if-theres-no-brexit-deal
    /government/publications/flights-to-and-from-the-uk-if-theres-no-brexit-deal
    /government/publications/geo-blocking-of-online-content-if-theres-no-brexit-deal
    /government/publications/mobile-roaming-if-theres-no-brexit-deal
    /government/publications/providing-services-including-those-of-a-qualified-professional-if-theres-no-brexit-deal
    /government/publications/rail-transport-if-theres-no-brexit-deal
    /government/publications/recognition-of-seafarer-certificates-of-competency-if-theres-no-brexit-deal
    /government/publications/taking-horses-abroad-if-theres-no-brexit-deal--2
    /government/publications/taking-your-pet-abroad-if-theres-no-brexit-deal
    /government/publications/travelling-in-the-common-travel-area-if-theres-no-brexit-deal
    /government/publications/travelling-to-the-eu-with-a-uk-passport-if-theres-no-brexit-deal
    /government/publications/travelling-with-a-european-firearms-pass-if-theres-no-brexit-deal
    /government/publications/uk-governments-preparations-for-a-no-deal-scenario
    /government/publications/upholding-environmental-standards-if-theres-no-brexit-deal
    /government/publications/vehicle-insurance-if-theres-no-brexit-deal
    /government/publications/workplace-rights-if-theres-no-brexit-deal
    /guidance/ecmt-international-road-haulage-permits
    /guidance/eu-community-licences-for-international-road-haulage
    /guidance/exiting-the-european-union
    /guidance/international-authorisations-and-permits-for-road-haulage
    /guidance/passport-rules-for-travel-to-europe-after-brexit
    /guidance/pet-travel-to-europe-after-brexit
    /guidance/prepare-to-drive-in-the-eu-after-brexit
  )

  attr_reader :base_path, :filter_params

  def fetch_content_item
    if development_env_finder_json
      JSON.parse(File.read(development_env_finder_json))
    else
      Services.content_store.content_item(base_path)
    end
  end

  def development_env_finder_json
    return news_and_communications_json if is_news_and_communications?
    return eu_exit_individuals_json if is_eu_exit_individuals_json?

    ENV["DEVELOPMENT_FINDER_JSON"]
  end

  def news_and_communications_json
    # Hard coding this in during development
    "features/fixtures/news_and_communications.json"
  end

  def eu_exit_individuals_json
    # Hard coding this in during development
    "features/fixtures/eu_exit_individuals.json"
  end

  def fetch_search_response(content_item)
    query_filter_params = filter_params.dup

    if query_filter_params.key?('topic')
      query_filter_params['topic'] = Services.content_store.content_item(query_filter_params['topic'])['content_id']
    end

    query = query_builder_class.new(
      finder_content_item: content_item,
      params: query_filter_params,
    ).call

    query = TranslateContentPurposeFields.new(query).call

    response = Services.rummager.search(query).to_hash
    response['results'] = response['results'].select { |result| BASE_PATHS.include?(result['link']) }
    response['total'] = response['results'].size
    response
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
      facet['allowed_values'] = allowed_values_for_facet_details(facet_key, facet_details) if facet
    end
  end

  def allowed_values_for_facet_details(facet_key, facet_details)
    facet_details.fetch("options", {})
      .map { |f| f.fetch("value", {}) }
      .map { |value| present_facet_option(value, facet_key) }
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

  def is_news_and_communications?
    base_path == "/news-and-communications"
  end

  def is_eu_exit_individuals_json?
    base_path == "/prepare-individual-uk-leaving-eu"
  end

  def registries
    @registries ||= Registries::BaseRegistries.new
  end
end
