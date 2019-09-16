class FindersController < ApplicationController
  include FinderTopResultAbTestable
  include SearchClusterABTestable

  layout "finder_layout"
  before_action :remove_search_box

  before_action do
    expires_in(5.minutes, public: true)
  end

  ATOM_FEED_MAX_AGE = 300
  def show
    respond_to do |format|
      format.html do
        @search_query = initialize_search_query
        @breadcrumbs = fetch_breadcrumbs
        @parent = parent
        @sort_presenter = sort_presenter
        @pagination = pagination_presenter
        @suggestions = suggestions
      end
      format.json do
        @search_query = initialize_search_query
        if content_item.is_search? || content_item.is_finder?
          render json: json_response
        else
          render json: {}, status: :not_found
        end
      end
      format.atom do
        @search_query = initialize_search_query(is_for_feed: true)
        if content_item.is_redirect?
          redirect_to_destination
        else
          expires_in(ATOM_FEED_MAX_AGE, public: true)
          @feed = AtomPresenter.new(finder_presenter, results, facet_tags)
        end
      end
    end
  rescue ActionController::UnknownFormat
    render plain: 'Not acceptable', status: :not_acceptable
  end

private

  attr_accessor :search_query

  helper_method :finder_presenter, :facet_tags, :i_am_a_topic_page_finder, :result_set_presenter, :content_item, :signup_links

  def redirect_to_destination
    @redirect = content_item.redirect
    @finder_slug = finder_slug
    render 'finders/show-redirect'
  end

  def json_response
    {
      total: result_set_presenter.displayed_total,
      facet_tags: render_component("facet_tags", facet_tags.present),
      search_results: render_component("finders/search_results", result_set_presenter.search_results_content),
      sort_options_markup: render_component("finders/sort_options", sort_presenter.to_hash),
      next_and_prev_links: render_component("govuk_publishing_components/components/previous_and_next_navigation", pagination_presenter.next_and_prev_links),
      suggestions: suggestions,
    }
  end

  def render_component(partial, locals)
    (render_to_string(formats: %w[html], partial: partial, locals: locals) || "").squish
  end

  def content_item
    @content_item ||= ContentItem.from_content_store(finder_base_path)
  end

  def result_set_presenter
    @result_set_presenter ||= result_set_presenter_class.new(
      finder_presenter,
      results,
      filter_params,
      sort_presenter,
      content_item.metadata_class,
      show_top_result?,
      debug_score?,
    )
  end

  def results
    @results ||= ResultSetParser.parse(
      search_results.fetch("results"),
      search_results.fetch("start", 0),
      search_results.fetch("total")
    )
  end

  def result_set_presenter_class
    return GroupedResultSetPresenter if grouped_display?

    ResultSetPresenter
  end

  def facets
    @facets ||= FacetsBuilder.new(content_item: content_item, search_results: search_results, value_hash: filter_params).facets
  end

  def signup_links
    @signup_links ||= SignupLinksPresenter.new(content_item, facets).signup_links
  end

  def finder_presenter
    @finder_presenter ||= FinderPresenter.new(
      content_item,
      facets,
      filter_params,
    )
  end

  def initialize_search_query(is_for_feed: false)
    Search::Query.new(
      content_item,
      filter_params,
      override_sort_for_feed: is_for_feed,
      ab_params: search_cluster_ab_params,
    )
  end

  def content_item_with_search_results
    @content_item_with_search_results ||= search_query.content_item_with_search_results
  end

  def fetch_breadcrumbs
    parent_slug = params["parent"]
    org_info = organisation_registry[parent_slug] if parent_slug.present?
    FinderBreadcrumbsPresenter.new(org_info, content_item)
  end

  def sort_presenter
    @sort_presenter ||= content_item.sorter_class.new(content_item, filter_params)
  end

  def pagination_presenter
    PaginationPresenter.new(
      per_page: content_item.default_documents_per_page,
      start_offset: search_results.dig('start'),
      total_results: search_results.dig('total'),
      url_builder: finder_url_builder,
    )
  end

  def search_results
    search_query.search_results
  end

  def suggestions
    search_results.fetch('suggested_queries', []).map do |keywords|
      {
        keywords: keywords,
        link: finder_url_builder.url(keywords: keywords),
      }
    end
  end

  def finder_url_builder
    UrlBuilder.new(content_item.base_path, filter_params)
  end

  def parent
    params.fetch(:parent, '')
  end

  def facet_tags
    @facet_tags ||= FacetTagsPresenter.new(
      finder_presenter,
      sort_presenter,
      i_am_a_topic_page_finder: i_am_a_topic_page_finder,
    )
  end

  def grouped_display?
    params["order"] == "topic" || sort_presenter.default_value == "topic"
  end

  def remove_search_box
    hide_site_serch = params['slug'] == 'search/all'
    set_slimmer_headers(remove_search: hide_site_serch)
  end

  def i_am_a_topic_page_finder
    @i_am_a_topic_page_finder ||= taxonomy_registry.taxonomy.key? params[:topic]
  end

  def taxonomy_registry
    Services.registries.all['full_topic_taxonomy']
  end

  def organisation_registry
    Services.registries.all['organisations']
  end

  def debug_score?
    params[:debug_score]
  end
end
