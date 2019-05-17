class FindersController < ApplicationController
  include FinderTopResultAbTestable

  layout "finder_layout"
  before_action :remove_search_box

  before_action do
    expires_in(5.minutes, public: true)
  end

  ATOM_FEED_MAX_AGE = 300

  def show
    respond_to do |format|
      format.html do
        @results = results
        @raw_content_item = content_item.as_hash
        @breadcrumbs = fetch_breadcrumbs
        @parent = parent
        @sort_presenter = sort_presenter
      end
      format.json do
        if content_item.is_search? || content_item.is_finder?
          render json: {
            total: results.displayed_total,
            facet_tags: render_component("facet_tags", results.facet_tags_content),
            search_results: render_component("finders/search_results", results.search_results_content),
            sort_options_markup: render_component("finders/sort_options", sort_presenter.to_hash),
            next_and_prev_links: render_component("govuk_publishing_components/components/previous_and_next_navigation", results.next_and_prev_links),
          }
        else
          render json: {}, status: :not_found
        end
      end
      format.atom do
        if content_item.is_redirect?
          @redirect = content_item.as_hash.dig('redirects', 0, 'destination')
          @finder_slug = finder_slug
          render 'finders/show-redirect'
        elsif finder.atom_feed_enabled?
          expires_in(ATOM_FEED_MAX_AGE, public: true)
          @feed = AtomPresenter.new(finder, results)
        else
          render plain: 'Not found', status: :not_found
        end
      end
    end
  rescue ActionController::UnknownFormat
    render plain: 'Not acceptable', status: :not_acceptable
  end

private

  def render_component(partial, locals)
    (render_to_string(formats: %w[html], partial: partial, locals: locals) || "").squish
  end

  def content_item
    @content_item ||= ContentItem.new(finder_base_path)
  end

  def results
    @results ||= result_set_presenter_class.new(
      finder,
      filter_params,
      sort_presenter,
      content_item.metadata_class,
      show_top_result?,
      debug_score?,
    )
  end

  def finder
    @finder ||= finder_presenter_class.new(
      raw_finder,
      finder_api.search_results,
      sort_presenter,
      filter_params,
    )
  end
  helper_method :finder

  def finder_api
    @finder_api ||= finder_api_class.new(content_item.as_hash, filter_params)
  end

  def raw_finder
    @raw_finder ||= finder_api.content_item_with_search_results
  end

  def fetch_breadcrumbs
    parent_slug = params["parent"]
    org_info = org_registry[parent_slug] if parent_slug.present?
    FinderBreadcrumbsPresenter.new(org_info, content_item.as_hash)
  end

  def finder_presenter_class
    FinderPresenter
  end

  def finder_api_class
    FinderApi
  end

  def result_set_presenter_class
    return GroupedResultSetPresenter if grouped_display?

    ResultSetPresenter
  end

  def sort_presenter
    @sort_presenter ||= content_item.sorter_class.new(content_item.as_hash, filter_params)
  end

  def org_registry
    @org_registry ||= Registries::OrganisationsRegistry.new
  end

  def parent
    params.fetch(:parent, '')
  end

  def grouped_display?
    params["order"] == "topic" || sort_presenter.default_value == "topic"
  end

  def remove_search_box
    hide_site_serch = params['slug'] == 'search/all'
    set_slimmer_headers(remove_search: hide_site_serch)
  end

  def debug_score?
    params[:debug_score]
  end
end
