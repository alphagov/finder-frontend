Given(/^a collection of documents exist$/) do
  content_store_has_mosw_reports_finder
  stub_rummager_api_request
end

Then(/^I can get a list of all documents with matching metadata$/) do
  visit finder_path('mosw-reports')

  expect(page).not_to have_content('2 reports')
  expect(page).to have_css('.filtered-results .document', count: 2)
  expect(page).to have_css('.gem-c-metadata')

  within '.filtered-results .document:nth-child(1)' do
    expect(page).to have_link(
      'West London wobbley walk',
      href: '/mosw-reports/west-london-wobbley-walk',
    )
    expect(page).to have_content('30 December 2003')
    expect(page).to have_content('Backward')
  end

  visit_filtered_finder('walk_type' => 'hopscotch')

  expect(page).to have_content('1 report')
  expect(page).to have_css('.filtered-results .document', count: 1)
end

When(/^I search documents by keyword$/) do
  stub_keyword_search_api_request

  visit finder_path('mosw-reports')

  @keyword_search = "keyword searchable"

  within '.filtering' do
    fill_in("Search", with: @keyword_search)
  end

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
  expect(page).to have_css('#proposition-menu')
end

Then(/^I can see documents which are marked as being in history mode$/) do
  expect(page).to have_css('p.historic', count: 5)
  expect(page).to have_content("2005 to 2010 Labour government")
end

Then(/^I can see documents which have government metadata$/) do
  within '.filtered-results .document:nth-child(1)' do
    expect(page).to have_content('Updated:')
    expect(page).to have_css('dl time[datetime="2007-02-14"]')

    expect(page).to have_content('News Story')

    expect(page).to have_content('Ministry of Justice')
  end
end

Given(/^a collection of documents with bad metadata exist$/) do
  content_store_has_mosw_reports_finder
  stub_rummager_api_request_with_bad_data
end

Then(/^I can get a list of all documents with good metadata$/) do
  visit finder_path('mosw-reports')
  expect(page).to have_css('.filtered-results .document', count: 2)

  within '.filtered-results .document:nth-child(1)' do
    expect(page).to have_content('Backward')
    expect(page).not_to have_content('England')
  end

  within '.filtered-results .document:nth-child(2)' do
    expect(page).to have_content('Northern Ireland')
    expect(page).not_to have_content('Hopscotch')
  end
end

Given(/^a policy finder exists$/) do
  content_store_has_policy_finder
  stub_rummager_api_request_with_policy_results
end

Given(/^a collection of documents that can be filtered by dates$/) do
  stub_content_store_with_cma_cases_finder
  stub_rummager_with_cma_cases
end

When(/^I use a date filter$/) do
  visit_cma_cases_finder
  apply_date_filter
end

Then(/^I only see documents with matching dates$/) do
  assert_cma_cases_are_filtered_by_date
end

Given(/^a finder with a dynamic filter exists$/) do
  content_store_has_policies_finder
  stub_rummager_api_request_with_policies_finder_results
end

Then(/^I can see filters based on the results$/) do
  visit finder_path('government/policies')

  within '.app-c-option-select' do
    expect(page).to have_selector('input#organisations-ministry-of-justice')
    expect(page).to have_content('Ministry of Justice')
  end
end

Given(/^a finder with paginated results exists$/) do
  content_store_has_policy_finder
  stub_rummager_api_request_with_policy_results
end

Then(/^I can see pagination$/) do
  visit finder_path('government/policies/benefits-reform')

  expect(page).not_to have_content('Previous page')
  expect(page).to have_content('Next page')
end

Then(/^I can browse to the next page$/) do
  stub_rummager_api_request_with_page_2_policy_results
  visit finder_path('government/policies/benefits-reform', page: 2)

  expect(page).to have_content('Previous page')
  expect(page).not_to have_content('Next page')
end

Given(/^a finder with description exists$/) do
  stub_content_store_with_cma_cases_finder_with_description
  stub_rummager_with_cma_cases
end

When(/I can see that the description in the metadata is present$/) do
  visit "/cma-cases"

  desc_text = "Find reports and updates on current and historical CMA investigations"
  desc_tag = "meta[name='description'][content='#{desc_text}']"
  expect(page).to have_css(desc_tag, visible: false)
end
