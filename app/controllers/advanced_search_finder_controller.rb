# typed: true
class AdvancedSearchFinderController < FindersController
  layout "advanced_search_layout"
  rescue_from AdvancedSearchFinderApi::TaxonNotFound,
              Supergroups::NotFound, with: :error_not_found

private

  def finder_presenter_class
    AdvancedSearchFinderPresenter
  end

  def finder_api_class
    AdvancedSearchFinderApi
  end

  def result_set_presenter_class
    AdvancedSearchResultSetPresenter
  end

  def finder_base_path
    request.path
  end
end
