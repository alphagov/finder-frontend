Given(/^a collection of documents exist$/) do
  content_store_has_mosw_reports_finder
  stub_rummager_api_request
end

Then(/^I can get a list of all documents with matching metadata$/) do
  visit finder_path('mosw-reports')
  page.should_not have_content('2 reports')
  page.should have_css('.filtered-results .document', count: 2)
  page.should have_css(shared_component_selector('metadata'))

  within '.filtered-results .document:nth-child(1)' do
    page.should have_link(
      'West London wobbley walk',
      href: '/mosw-reports/west-london-wobbley-walk',
    )
    page.should have_content('30 December 2003')
    page.should have_content('Backward')
  end

  select_filters('Walk type' => 'Hopscotch')

  page.should have_content('1 report')
  page.should have_css('.filtered-results .document', count: 1)
end

When(/^I search documents by keyword$/) do
  stub_keyword_search_api_request

  visit finder_path('mosw-reports')

  @keyword_search = "keyword searchable"
  fill_in("Search", with: @keyword_search)
  click_on "Filter results"
end

Then(/^I see all documents which contain the keywords$/) do
  within ".filtered-results" do
    expect(page).to have_css("a", text: @keyword_search)
  end
end

Given(/^a government finder exists$/) do
  content_store_has_government_finder
  stub_rummager_api_request_with_government_results
end

Then(/^I can see the government header$/) do
  visit finder_path('government/policies/benefits-reform')
  page.should have_css(shared_component_selector('government_navigation'))
end

Then(/^I can see documents which have government metadata$/) do
  page.should have_css('p.historic', count: 1)
  page.should have_content("2005 to 2010 Labour government")
end
