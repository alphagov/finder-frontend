Given /^no search results exist$/ do
  @results = []
  stub_rummager_results(@results)
  content_store_has_item("/search", schema: 'special_route')
end

Given /^search results exist$/ do
  @results = [
    { "title_with_highlighting" => "document-title", "link" => "/document-slug" },
    result_with_organisation("CO", "Cabinet Office", "cabinet-office"),
    result_with_organisation("Home Office", "Home Office", "home-office")
  ]
  stub_rummager_results(@results, "search-term", ["searching-term"])
  content_store_has_item("/search", schema: 'special_route')
end

Given(/^search results for multiple governments exists$/) do
  @historical_result_with_government_name = {
    "title_with_highlighting" => "Historical with government",
    "description_with_highlighting" => "DESCRIPTION",
    "is_historic" => true,
    "government_name" => "XXXX to YYYY Example government",
    "link" => "/url",
    "index" => "government"
  }
  @non_historical_result = {
    "title_with_highlighting" => "Non historical",
    "description_with_highlighting" => "DESCRIPTION",
    "is_historic" => false,
    "government_name" => nil,
    "link" => "/url",
    "index" => "government"
  }
  @historical_result_without_government_name = {
    "title_with_highlighting" => "Historical without government",
    "description_with_highlighting" => "DESCRIPTION",
    "is_historic" => true,
    "government_name" => nil,
    "link" => "/url",
    "index" => "government"
  }

  stub_rummager_results([
    @historical_result_with_government_name,
    @non_historical_result,
    @historical_result_without_government_name,
  ])
  content_store_has_item("/search", schema: 'special_route')
end

Given(/^multiple pages of search results exists$/) do
  results = Array.new(50, {})
  stub_rummager_results(results)
  content_store_has_item("/search", schema: 'special_route')
end

Given(/^external urls exist in the of search results$/) do
  @long_external_link = {
    "title_with_highlighting" => "long external link",
    "description_with_highlighting" => "This is a description",
    "link" => "http://www.weally.weally.long.url.com/weaseling/about/the/world",
    "section" => "driving",
    "format" => "recommended-link"
  }
  @http_external_link = {
    "title_with_highlighting" => "http external link",
    "description_with_highlighting" => "This is a description",
    "link" => "http://www.badgers.com/http",
    "format" => "recommended-link"
  }
  @https_external_link = {
    "title_with_highlighting" => "https external link",
    "description_with_highlighting" => "This is a description",
    "link" => "https://www.badgers.com/https",
    "format" => "recommended-link"
  }

  stub_rummager_results([
    @long_external_link,
    @http_external_link,
    @https_external_link,
  ])
  content_store_has_item("/search", schema: 'special_route')
end

Given(/^the search API returns an error state$/) do
  allow(SearchAPI).to receive(:new).and_raise(GdsApi::BaseError)
  content_store_has_item("/search", schema: 'special_route')
end

When(/^I search for an empty string$/) do
  visit '/search?q='
end

When(/^I search for "([^"]*)"$/) do |search_term|
  visit "/search?q=#{search_term}"
end

When(/^I search for "([^"]*)" from "([^"]*)"$/) do |search_term, organisation|
  visit "/search?q=#{search_term}&filter_organisations=#{organisation}"
end

When(/^I search for "([^"]*)" on the json endpoint$/) do |search_term|
  visit "/search.json?q=#{search_term}"
end

When(/^I search for "([^"]*)" with manuals filter$/) do |search_term|
  visit "/search.json?q=#{search_term}filter_manual[]=manual-to-filter-on"
end

When(/^I search for "([^"]*)" with show organisation flag$/) do |search_term|
  visit "/search?q=#{search_term}&show_organisations_filter=true"
end

When(/^I search with bad parameters$/) do
  visit "/search?q=search-term&start=999999"
end

When(/^I navigate to the next page$/) do
  click_on "Next page"
end

Then /^I am able to set search terms$/ do
  expect(page).to have_field('Search GOV.UK', with: '')
end

Then(/^I am able to see the document in the search results$/) do
  @results.each do |result|
    expect(page).to have_link(result["title_with_highlighting"], href: result["link"])
  end
end

Then(/^I am able to see organisations with abbreviations$/) do
  @results.each do |result|
    acronym = result.dig("organisations", 0, "acronym")
    next unless acronym

    org_title = result.dig('organisations', 0, 'title')
    if org_title != acronym
      within("ul.attributes li", text: acronym) do
        expect(page).to have_css("abbr[title='#{org_title}']", text: acronym)
      end
    end
  end
end

Then(/^I am able to see organisations without abbreviations$/) do
  @results.each do |result|
    acronym = result.dig("organisations", 0, "acronym")
    next unless acronym

    org_title = result.dig('organisations', 0, 'title')
    if org_title == acronym
      within("ul.attributes li", text: acronym) do
        expect(page).to have_no_css("abbr[title='#{org_title}']")
      end
    end
  end
end

Then(/^I can see that no search results were found$/) do
  expect(page).to have_content("Please try:")
  expect(page).to have_content("searching again using different words")
end

Then(/^search results for previous known governments are tagged as such$/) do
  within("li", text: @historical_result_with_government_name["title_with_highlighting"]) do
    expect(page).to have_css(".historic", text: "XXXX to YYYY Example government")
  end
  within("li", text: @non_historical_result["title_with_highlighting"]) do
    expect(page).to have_no_css(".historic")
  end
  within("li", text: @historical_result_without_government_name["title_with_highlighting"]) do
    expect(page).to have_no_css(".historic")
  end
end

Then(/^I can see search suggestions$/) do
  expect(page).to have_content("Did you mean searching-term")
  expect(page).to have_link("searching-term", href: /filter_organisations=hm-revenue-customs/)
end

Then(/^Organisations filter should be expanded$/) do
  expect(page).to have_css('.app-c-option-select input')
  expect(page).to have_no_css('.app-c-option-select[data-closed-on-load="true"]')
end

Then(/^Organisations filter should not be expanded$/) do
  expect(page).to have_css('.app-c-option-select[data-closed-on-load="true"]')
end

Then(/^Organisations filter should not be displayed$/) do
  expect(page).to have_no_css('.app-c-option-select')
end

Then /^I can see the search term$/ do
  expect(page).to have_field('Search results for', with: 'search-term')
end

Then(/^I should see a link to the next page$/) do
  expect(page).to have_content("Next page")
end

Then(/^I should see a link to the previous page$/) do
  expect(page).to have_content("Previous page")
end

Given(/^the search API returns an HTTP unprocessable entity error$/) do
  allow(SearchAPI).to receive(:new).and_raise(GdsApi::HTTPUnprocessableEntity.new(422))
  content_store_has_item("/search", schema: 'special_route')
end

Then(/^I should get a bad request error$/) do
  expect(page.status_code).to eq(422)
end

Then(/^Analytics values are sent$/) do
  meta = find('meta[name="govuk:search-result-count"]', visible: false)
  expect(meta.native.attribute('content').value).to eq('200')
end

Then(/^long urls should be truncated$/) do
  expect(page).to have_link(@long_external_link['title_with_highlighting'], href: @long_external_link['link'])
  expect(page).to have_css("a[rel=external]", text: @long_external_link['title_with_highlighting'])
  within('li', text: @long_external_link['title_with_highlighting']) do
    expect(page).to have_css('.url', text: "www.weally.weally.long.url.com/weaseling/abou...")
  end
end

Then(/^links should be schema\-less$/) do
  expect(page).to have_link(@http_external_link['title_with_highlighting'], href: @http_external_link['link'])
  within('li', text: @http_external_link['title_with_highlighting']) do
    expect(page).to have_css('.url', text: "www.badgers.com/http")
  end

  expect(page).to have_link(@https_external_link['title_with_highlighting'], href: @https_external_link['link'])
  within('li', text: @https_external_link['title_with_highlighting']) do
    expect(page).to have_css('.url', text: "www.badgers.com/https")
  end
end

Then(/^I should get a valid JSON response$/) do
  json = JSON.parse(page.body)

  # the actual amount of data returned
  expect(json["results"].length).to eq(@results.count)
  # 200 = mocked value for dataset size
  expect(json["result_count"]).to eq(200)
  expect(json["result_count_string"]).to eq("200 results")
end

Then(/^I should get an error page$/) do
  expect(page.status_code).to eq(503)
end

Then("the search term is escaped") do
  expect(page.body.to_s).not_to match("<script>XSS</script>")
end

module RummagerStubber
  def stub_rummager_results(results, _query = "search-term", suggestions = [], options = {})
    response_body = response(results, suggestions, options)
    allow(SearchAPI).to receive(:new).and_return(double(:api, search: response_body))
  end

  def stub_single_rummager_result(result)
    stub_results([result])
  end

  def response(results, suggestions = [], options = {})
    {
      "results" => results,
      "facets" => {
        "organisations" => {
          "options" =>
            [
              { "value" =>
                {
                  "slug" => "ministry-of-silly-walks",
                  "link" => "/government/organisations/ministry-of-silly-walks",
                  "title" => "Ministry of Silly Walks",
                  "acronym" => "MOSW",
                  "organisation_type" => "Ministerial department",
                  "organisation_state" => "live"
                },
                "documents" => 12 }
            ],
          "documents_with_no_value" => 1619,
          "total_options" => 139,
          "missing_options" => 39,
        }
      },
      "suggested_queries" => suggestions,
      "total" => options[:total] || 200,
    }
  end

  def result_with_organisation(acronym, title, slug)
    {
      "title_with_highlighting" => "Something by #{title}",
      "link" => "/some-link",
      "format" => "something",
      "es_score" => 0.1,
      "index" => "government",
      "organisations" => [
        {
          "acronym" => acronym,
          "title" => title,
          "slug" => slug,
        }
      ]
    }
  end

  def stub_no_rummager_results
    response([])
  end
end

World(RummagerStubber)
