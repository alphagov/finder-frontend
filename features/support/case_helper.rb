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
    "#{Plek.current.find('finder-api')}/finders/cma-cases/documents.json?case_type[]=mergers"
  end

  def all_cases_json
    %|{
      "results": [
        {
          "title": "HealthCorp / DrugInc merger inquiry",
          "slug": "cma-cases/healthcorp-druginc-merger-inquiry",
          "opened_date": "2003-12-30",
          "closed_date": "2004-03-01",
          "summary": "Inquiry into the HealthCorp / DrugInc merger",

          "market_sector": {
            "value": "pharmaceuticals",
            "label": "Pharmaceuticals"
          },
          "case_type": {
            "value": "mergers",
            "label": "Mergers"
          },
          "outcome_type": {
            "value": "ca98-infringement-chapter-i",
            "label": "CA98 - infringement Chapter I"
          },
          "case_state": {
            "value": "closed",
            "label": "Closed"
          }
        },
        {
          "title": "Private healthcare market investigation",
          "slug": "cma-cases/private-healthcare-market-investigation",
          "opened_date": "2007-08-14",
          "closed_date": "2008-03-01",
          "summary": "Inquiry into the private healthcare market",

          "market_sector": {
            "value": "pharmaceuticals",
            "label": "Pharmaceuticals"
          },
          "case_type": {
            "value": "markets",
            "label": "Markets"
          },
          "outcome_type": {
            "value": "ca98-infringement-chapter-i",
            "label": "CA98 - infringement Chapter I"
          },
          "case_state": {
            "value": "closed",
            "label": "Closed"
          }
        }
      ]
    }|
  end

  def merger_inquiry_cases_json
    %|{
      "results": [
        {
          "title": "HealthCorp / DrugInc merger inquiry",
          "slug": "cma-cases/healthcorp-druginc-merger-inquiry",
          "opened_date": "2003-12-30",
          "closed_date": "2004-03-01",
          "summary": "Inquiry into the HealthCorp / DrugInc merger",

          "market_sector": {
            "value": "pharmaceuticals",
            "label": "Pharmaceuticals"
          },
          "case_type": {
            "value": "mergers",
            "label": "Mergers"
          },
          "outcome_type": {
            "value": "ca98-infringement-chapter-i",
            "label": "CA98 - infringement Chapter I"
          },
          "case_state": {
            "value": "closed",
            "label": "Closed"
          }
        }
      ]
    }|
  end

  def select_filters(facets = {})
    within ".facet-menu" do
      facets.values.each do |value|
        check(value)
      end
      click_on "Filter results"
    end
  end
end

World(CaseHelper)
