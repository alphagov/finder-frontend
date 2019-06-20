# typed: true
# The UrlBuilder class is responsible for creating URLs to be rendered as
# HTML links.
class UrlBuilder
  def initialize(path, query_params = {})
    @path = path
    @query_params = query_params
  end

  def url(additional_params = {})
    [
      path,
      query_params.merge(additional_params).to_query,
    ].reject(&:blank?).join("?")
  end

private

  attr_reader :path, :query_params
end
