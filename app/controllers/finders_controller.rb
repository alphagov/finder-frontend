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
          @feed = AtomPresenter.new(finder)
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
    result_set_presenter_class.new(finder, filter_params, view_context)
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
    parent_content_item = {}
    unless params.dig("parent_path").to_s.empty?
      begin
        parent_content_item = Services.content_store.content_item(params["parent_path"])
      rescue GdsApi::HTTPNotFound
        #parent_path is user input so we don't mind if it's bad
        GovukStatsd.increment("breadcrumb.parent_path_not_found")
      end
    end
    FinderBreadcrumbsPresenter.new(parent_content_item, @content_item)
  end

  def filter_params
    # TODO Use a whitelist based on the facets in the schema
    @filter_params ||= begin
      permitted_params = params
                           .to_unsafe_hash
                           .except(
                             :controller,
                             :action,
                             :slug,
                             :format
                           )

      ParamsCleaner
        .new(permitted_params)
        .cleaned
        .delete_if { |_, value| value.blank? }
    end
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
end
