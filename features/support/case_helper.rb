module CaseHelper
  def stub_case_collection_api_request
    stub_request(:get, finder_api_all_cases_url).to_return(
      body: all_cases_json,
      headers: { 'Content-Type' => 'application/json' }
    )

    stub_request(:get, finder_api_merger_inquiry_cases_url).to_return(
      body: merger_inquiry_cases_json,
      headers: { 'Content-Type' => 'application/json' }
    )
  end

  def finder_api_all_cases_url
    "#{Plek.current.find('finder-api')}/finders/cma-cases/documents.json"
  end

  def finder_api_merger_inquiry_cases_url
    "#{Plek.current.find('finder-api')}/finders/cma-cases/documents.json?case_type=merger-inquiries"
  end

  def all_cases_json
    {
      document_noun: 'case',
      documents: [
        {
          title: 'HealthCorp / DrugInc merger inquiry',
          metadata: [
            { type: 'date', name: 'date_referred', value: '2003-12-30' },
            { type: 'text', name: 'case_type', value: 'Merger inquiry' }
          ]
        },
        {
          title: 'Private healthcare market investigation',
          metadata: [
            { type: 'date', name: 'date_referred', value: '2007-08-14' },
            { type: 'text', name: 'case_type', value: 'Market investigation' }
          ]
        }
      ]
    }.to_json
  end

  def merger_inquiry_cases_json
    {
      document_noun: 'case',
      documents: [
        {
          title: 'HealthCorp / DrugInc merger inquiry',
          metadata: [
            { type: 'date', name: 'date_referred', value: '2003-12-30' },
            { type: 'text', name: 'case_type', value: 'Merger inquiry' }
          ]
        }
      ]
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
