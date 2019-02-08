class FindersController < ApplicationController
  layout "finder_layout"

  before_action do
    expires_in(5.minutes, public: true)
  end

  ATOM_FEED_MAX_AGE = 300

  def show
    respond_to do |format|
      format.html do
        @results = results
        @content_item = raw_finder
        @breadcrumbs = fetch_breadcrumbs
      end
      format.json do
        if %w[finder search].include? finder_api.content_item['document_type']
          render json: results
        else
          render json: {}, status: :not_found
        end
      end
      format.atom do
        if finder_api.content_item['document_type'] == 'redirect'
          @redirect = finder_api.content_item.dig('redirects', 0, 'destination')
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

  def results
    @results ||= result_set_presenter_class.new(finder, filter_params, view_context)
  end

  def finder
    @finder ||= finder_presenter_class.new(
      raw_finder,
      filter_params,
    )
  end
  helper_method :finder

  def finder_api
    @finder_api ||= finder_api_class.new(
      finder_base_path,
      filter_params
    )
  end

  def raw_finder
    @raw_finder ||= finder_api.content_item_with_search_results
  end

  def fetch_breadcrumbs
    parent_slug = params["parent"]
    org_info = org_registry[parent_slug] if parent_slug.present?
    FinderBreadcrumbsPresenter.new(org_info, @content_item)
  end

  def finder_presenter_class
    FinderPresenter
  end

  def finder_api_class
    FinderApi
  end

  def result_set_presenter_class
    ResultSetPresenter
  end

  def org_registry
    @org_registry ||= Registries::OrganisationsRegistry.new
  end
end
