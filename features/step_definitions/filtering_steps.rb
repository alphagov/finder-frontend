Given(/^a collection of cases exist$/) do
  stub_finder_artefact_api_request
  stub_case_collection_api_request
end

Then(/^I can get a list of all merger inquiries$/) do
  stub_finder_artefact_api_request
  visit finder_path('cma-cases')
  page.should_not have_content('2 cases')
  page.should have_css('a', text: 'Competition and Markets Authority')
  page.should have_css('.filtered-results .document', count: 2)

  within '.filtered-results .document:nth-child(1)' do
    page.should have_link('HealthCorp / DrugInc merger inquiry')
    page.should have_content('30 December 2003')
    page.should have_content('Mergers')
  end

  select_filters('Case type' => 'Mergers')

  page.should have_content('1 case')
  page.should have_css('.filtered-results .document', count: 1)
end

When(/^I search cases by keyword$/) do
  stub_finder_artefact_api_request
  stub_keyword_search_api_request

  visit finder_path('cma-cases')

  @keyword_search = "keyword searchable"
  fill_in("Search", with: @keyword_search)
  click_on "Filter results"
end

Then(/^I see all cases which contain the keywords$/) do
  within ".filtered-results" do
    expect(page).to have_css("a", text: @keyword_search)
  end
end
