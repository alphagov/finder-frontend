class AdvancedSearchFinderController < FindersController
  layout "advanced-search"

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
