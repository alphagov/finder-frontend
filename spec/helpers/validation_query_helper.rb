module ValidateQueryHelper
  def stub_valid_query
    params = {
      'filter_content_purpose_supergroup' => %w(news_and_communications),
      'filter_organisations' => %w(stories),
      'filter_people' => %w(harry-potter),
    }

    stub_query(params: params)
  end

  def stub_invalid_query
    stub_request(:get, "#{Plek.current.find('search')}/search.json?count=0&filter_blah=news&filter_invalid_param=stories&filter_people=harry-potter")
      .to_return(status: 422, body: { "error": "\"blah\" is not a valid filter field" }.to_json, headers: {})
  end

  def stub_validation_of_valid_query(params = {})
    stub_query(params: params)
  end

  def stub_query(params: {}, response: {}, response_code: 200)
    query = Rack::Utils.build_nested_query params.merge(default_params)
    stub_request(:get, "#{Plek.current.find('search')}/search.json?#{query}")
      .to_return(status: response_code, body: response.to_json, headers: {})
  end

  def default_params
    { 'count' => 0 }
  end
end
