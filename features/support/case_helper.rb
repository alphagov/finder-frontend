module CaseHelper
  def stub_case_collection_api_request
    stub_request(:get, finder_api_cma_cases_url).to_return(body: cases_json, :headers => { 'Content-Type' => 'application/json' })
  end

  def finder_api_cma_cases_url
    "#{Plek.current.find('finder-api')}/cma-cases"
  end

  def cases_json
    {
    }.to_json
  end

  def select_filters(facets = {})
    within ".facet-menu" do
      facets.each do |name, value|
        select(value, from: name)
      end
      click_on "Refresh results"
    end
  end
end

World(CaseHelper)
