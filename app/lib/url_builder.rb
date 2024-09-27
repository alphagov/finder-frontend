# The UrlBuilder class is responsible for creating URLs to be rendered as
# HTML links.
class UrlBuilder
  using HashWithDeepExcept

  def initialize(path, query_params = {})
    @path = path
    @query_params = query_params
  end

  def url(additional_params = {})
    build_url(query_params.merge(additional_params))
  end

  def url_except(excepted_param)
    build_url(query_params.deep_except(excepted_param))
  end

private

  attr_reader :path, :query_params

  def build_url(params)
    [
      path,
      params.to_query,
    ].reject(&:blank?).join("?")
  end
end
