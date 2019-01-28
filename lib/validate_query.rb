# This enables one to pass a query and check whether it is acceptable
# by rummager. It makes a quick query against the search api and checks whether
# the attributes throws errors.

class ValidateQuery
  def initialize(query_params = {})
    @query_params = query_params
  end

  # returns nil or an error message
  def validate
    @validate ||= search_params_have_errors?
  end

private

  def search_params_have_errors?
    Services.rummager.search(rummager_params)
    nil
  rescue GdsApi::HTTPUnprocessableEntity => error
    error.error_details.fetch("error", "Unprocessable request; please check your filters and try again.")
  end

  def rummager_params
    default_params.merge(@query_params.transform_keys { |key| "filter_#{key}" })
  end

  def default_params
    {
      "count" => 0,
    }
  end
end
