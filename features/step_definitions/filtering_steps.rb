Given(/^a collection of documents exist$/) do
  content_store_has_mosw_reports_finder
  stub_rummager_api_request
end

Then(/^I can get a list of all documents with matching metadata$/) do
  visit finder_path('mosw-reports')

  expect(page).to have_content('2 reports')
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

When(/^I view a list of news and communications$/) do
  content_store_has_news_and_communications_finder
  stub_whitehall_api_world_location_request
  stub_rummager_api_request_with_news_and_communication_results

  visit finder_path('news-and-communications')
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

Given(/^a finder tagged to the topic taxonomy$/) do
  stub_content_store_with_a_taxon_tagged_finder
  stub_rummager_with_cma_cases
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
  content_store_has_mosw_reports_finder
  stub_rummager_api_request
end

Then(/^I can see filters based on the results$/) do
  visit finder_path('mosw-reports')

  within first('.app-c-option-select') do
    expect(page).to have_selector('input#walk_type-backward')
    expect(page).to have_content('Hopscotch')
    expect(page).to_not have_selector('input#organisations-ministry-of-silly-walks')
  end
end

Given(/^a finder with paginated results exists$/) do
  content_store_has_government_finder_with_10_items
  stub_rummager_api_request_with_10_government_results
end

Then(/^I can see pagination$/) do
  visit finder_path('government/policies/benefits-reform')

  expect(page).not_to have_content('Previous page')
  expect(page).to have_content('Next page')
end

Then(/^I can browse to the next page$/) do
  stub_rummager_api_request_with_10_government_results_page_2
  visit finder_path('government/policies/benefits-reform', page: 2)

  expect(page).to have_content('Previous page')
  expect(page).not_to have_content('Next page')
end

Then(/^I browse to a huge page number and get an appropriate error$/) do
  stub_rummager_api_request_with_422_response(999999)
  visit finder_path('government/policies/benefits-reform', page: 999999)

  expect(page.status_code).to eq(422)
end

Then(/^I can see that Google won't index the page$/) do
  tag = "meta[name='robots'][content='noindex']"
  expect(page).to have_css(tag, visible: false)
end

Then(/^I can see that Google can index the page$/) do
  tag = "meta[name='robots'][content='noindex']"
  expect(page).not_to have_css(tag, visible: false)
end

Given(/^a finder with description exists$/) do
  stub_content_store_with_cma_cases_finder_with_description
  stub_rummager_with_cma_cases
end

When(/^I can see that the description in the metadata is present$/) do
  visit "/cma-cases"

  desc_text = "Find reports and updates on current and historical CMA investigations"
  desc_tag = "meta[name='description'][content='#{desc_text}']"
  expect(page).to have_css(desc_tag, visible: false)
end

Given(/^an organisation finder exists$/) do
  content_store_has_government_finder
  stub_rummager_api_request_with_government_results
  content_store_has_attorney_general_organisation

  visit finder_path('government/policies/benefits-reform', parent_path: '/government/organisations/attorney-generals-office')
end

Given(/^an organisation finder exists but a bad breadcrumb path is given$/) do
  content_store_has_government_finder
  stub_rummager_api_request_with_government_results
  content_store_is_missing_path

  visit finder_path('government/policies/benefits-reform', parent_path: '/bernard-cribbins')
end

Then(/^I can see a breadcrumb for home$/) do
  expect(page).to have_link("Home", href: "/")
  expect(page).to have_css("a[data-track-category='homeLinkClicked']", text: "Home")
  expect(page).to have_css("a[data-track-action='homeBreadcrumb']", text: "Home")
  expect(page).to have_css("a[data-track-label='']", text: "Home")
  expect(page).to have_css("a[data-track-options='{}']", text: "Home")
end

Then(/^I can see a breadcrumb for all organisations$/) do
  expect(page).to have_link("Organisations", href: "/government/organisations")
  expect(page).to have_css("a[data-track-category='breadcrumbClicked']", text: "Organisations")
  expect(page).to have_css("a[data-track-action='2']", text: "Organisations")
  expect(page).to have_css("a[data-track-label='/government/organisations']", text: "Organisations")
  expect(page).to have_css("a[data-track-options='{\"dimension28\":\"4\",\"dimension29\":\"Organisations\"}']", text: "Organisations")
end

And(/^no breadcrumb for all organisations$/) do
  expect(page).to_not have_link("Organisations", href: "/government/organisations")
end

Then(/^I can see a breadcrumb for the organisation$/) do
  expect(page).to have_link("Attorney General's Office", href: "/government/organisations/attorney-generals-office")
  expect(page).to have_css("a[data-track-category='breadcrumbClicked']", text: "Attorney General's Office")
  expect(page).to have_css("a[data-track-action='3']", text: "Attorney General's Office")
  expect(page).to have_css("a[data-track-label='/government/organisations/attorney-generals-office']", text: "Attorney General's Office")
  expect(page).to have_css("a[data-track-options='{\"dimension28\":\"4\",\"dimension29\":\"Attorney General\\'s Office\"}']", text: "Attorney General's Office")
end

Then(/^I can see a breadcrumb that not a link for the finder$/) do
  expect(page).to have_selector(".govuk-breadcrumbs__list-item", text: "Ministry of Silly Walks reports")
end

Then(/^I can see taxonomy breadcrumbs$/) do
  visit finder_path('cma-cases')
  expect(page).to have_selector(".govuk-breadcrumbs__list-item", text: "Competition Act and cartels")
  expect(page.find_all(".govuk-breadcrumbs__list-item").count).to eql(2)
end

Given(/^a collection of documents exist that can be filtered by checkbox$/) do
  stub_content_store_with_cma_cases_finder_for_supergroup_checkbox_filter
  stub_rummager_with_cma_cases_for_supergroups_checkbox
  visit_cma_cases_finder
end

When(/^I use a checkbox filter$/) do
  find("label", text: "Show open cases").click
  click_on "Filter results"
end

Then(/^I only see documents that match the checkbox filter$/) do
  expect(page).to have_content("1 case that is Open")

  within ".filtered-results .document:nth-child(1)" do
    expect(page).to have_content("Big Beer Co / Salty Snacks Ltd merger inquiry")
    expect(page).to_not have_content("Bakery market investigation")
  end
end

Then(/^The checkbox has the correct tracking data$/) do
  expect(page).to have_css("input[type='checkbox'][data-track-category='filterClicked']")
  expect(page).to have_css("input[type='checkbox'][data-track-action='checkboxFacet']")
  expect(page).to have_css("input[type='checkbox'][data-track-label='Open']")
  expect(page).to have_css("input[type='checkbox'][data-module='track-click']")
end

Then(/^I can sort by:$/) do |table|
  expect(find_all('.js-order-results option').collect(&:text)).to eq(table.raw.flatten)
end

When(/^I sort by most viewed$/) do
  select 'Most viewed', from: 'Sort by'
  click_on 'Filter results'
end

Then(/^I see the most viewed articles first$/) do
  within '.filtered-results .document:nth-child(1)' do
    expect(page).to have_content('Press release from Hogwarts')
    expect(page).to have_content('25 December 2017')
  end

  within '.filtered-results .document:nth-child(2)' do
    expect(page).to have_content('16 November 2018')
  end

  expect(page).to have_content('sorted by Most viewed')
end
