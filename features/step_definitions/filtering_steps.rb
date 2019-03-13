Given(/^a collection of documents exist$/) do
  content_store_has_mosw_reports_finder
  stub_rummager_api_request
end

Given(/^no results$/) do
  content_store_has_mosw_reports_finder_with_no_facets
  stub_rummager_api_request_with_no_results
end

When(/^I view the finder with no keywords and no facets$/) do
  visit finder_path('mosw-reports')
end

Then(/I see no results$/) do
  expect(page).to have_content('0 reports')
  expect(page).to have_css('.filtered-results .document', count: 0)
end

And(/there is no keyword search box$/) do
  expect(page).to_not have_css('#finder-keyword-search')
end

And(/there is a zero results message$/) do
  expect(page).to have_content('no matching results')
end

And(/there is not a zero results message$/) do
  expect(page).to_not have_content('no matching results')
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

And("I see email and feed sign up links") do
  expect(page).to have_css('a[href="/search/news-and-communications/email-signup?"]')
  expect(page).to have_css('a[href="/search/news-and-communications.atom"]')
end

And("I see email and feed sign up links with filters applied") do
  expect(page).to have_css('a[href="/search/news-and-communications/email-signup?people%5B%5D=rufus-scrimgeour"]')
  expect(page).to have_css('a[href="/search/news-and-communications.atom?order=updated-newest&people%5B%5D=rufus-scrimgeour&public_timestamp%5Bfrom%5D=&public_timestamp%5Bto%5D="]')
end

And("I see email and feed sign up links with filters applied with extra empty filters") do
  expect(page).to have_css('a[href="/search/news-and-communications/email-signup?parent=&keywords=&level_one_taxon=&people%5B%5D=rufus-scrimgeour&public_timestamp%5Bfrom%5D=&public_timestamp%5Bto%5D=&order=updated-newest"]')
  expect(page).to have_css('a[href="/search/news-and-communications.atom?parent=&keywords=&level_one_taxon=&people%5B%5D=rufus-scrimgeour&public_timestamp%5Bfrom%5D=&public_timestamp%5Bto%5D=&order=updated-newest"]')
end

When(/^I view a list of news and communications$/) do
  topic_taxonomy_has_taxons([
    {
      content_id: "Taxon_1",
      title: "Taxon_1"
    },
    {
      content_id: "Taxon_2",
      title: "Taxon_2"
    }
  ])
  content_store_has_news_and_communications_finder
  stub_whitehall_api_world_location_request
  stub_people_registry_request
  stub_organisations_registry_request
  stub_rummager_api_request_with_news_and_communication_results
  visit finder_path('search/news-and-communications')
end

When(/^I view the news and communications finder$/) do
  topic_taxonomy_has_taxons([
    {
      content_id: "Taxon_1",
      title: "Taxon_1"
    },
    {
      content_id: "Taxon_2",
      title: "Taxon_2"
    }
  ])
  content_store_has_news_and_communications_finder
  stub_whitehall_api_world_location_request
  stub_all_rummager_api_requests_with_news_and_communication_results
  stub_people_registry_request
  stub_organisations_registry_request
  visit finder_path('search/news-and-communications')
end

When(/^I view the business readiness finder$/) do
  content_store_has_business_readiness_finder
  stub_whitehall_api_world_location_request
  stub_rummager_api_request_with_business_readiness_results
  stub_rummager_api_request_with_filtered_business_readiness_results

  visit finder_path('find-eu-exit-guidance-business')
end

When(/^I view the policy papers and consultations finder$/) do
  topic_taxonomy_has_taxons([
    {
      content_id: "Taxon_1",
      title: "Taxon_1"
    },
    {
      content_id: "Taxon_2",
      title: "Taxon_2"
    }
  ])
  content_store_has_policy_and_engagement_finder
  stub_whitehall_api_world_location_request
  stub_rummager_api_request_with_policy_papers_results
  stub_rummager_api_request_with_filtered_policy_papers_results

  visit finder_path('search/policy-papers-and-consultations')
end

When(/^I view a list of services$/) do
  topic_taxonomy_has_taxons
  content_store_has_services_finder
  stub_rummager_api_request_with_services_results
  stub_people_registry_request
  stub_organisations_registry_request

  visit finder_path('search/services')
end

When(/^I search documents by keyword$/) do
  stub_keyword_search_api_request

  visit finder_path('mosw-reports')

  @keyword_search = "keyword searchable"

  within '.filter-form' do
    fill_in("Search", with: @keyword_search)
  end

  click_on "Filter results"
end

When(/^I search documents by keyword for business finder$/) do
  content_store_has_business_readiness_finder
  stub_keyword_business_readiness_search_api_request

  visit finder_path('find-eu-exit-guidance-business')

  @keyword_search = "keyword searchable"

  within '.filter-form' do
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
  stub_organisations_registry_request
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

When(/^I use a collection of documents exist that can be filtered by checkbox filter$/) do
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

And(/^filters are wrapped in a progressive disclosure element$/) do
  expect(page).to have_selector('#facet-wrapper')
end

And(/^filters are not wrapped in a progressive disclosure element$/) do
  expect(page).not_to have_selector('#facet-wrapper')
end

Given(/^a finder with autocomplete exists$/) do
  content_store_has_mosw_reports_finder_with_autocomplete_facet
  stub_rummager_api_request
end

Then(/^I can filter based on the results$/) do
  visit finder_path('mosw-reports')

  expect(page).to have_content("2 reports")
  within ".filtered-results" do
    expect(page).to have_content("West London wobbley walk")
    expect(page).to have_content("The Gerry Anderson")
  end

  within first('.gem-c-accessible-autocomplete') do
    expect(page).to have_selector('select#walk_type')
    select("Hopscotch", from: "walk_type").select_option
  end
  click_on "Filter results"

  within(".result-info") do
    expect(page).to have_content("1 report")
    expect(page).to have_content("Of Type")
    expect(page).to have_content("Hopscotch")
  end
  within ".filtered-results" do
    expect(page).not_to have_content("West London wobbley walk")
    expect(page).to have_content("The Gerry Anderson")
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
  stub_organisations_registry_request
  stub_rummager_api_request_with_government_results
  stub_people_registry_request

  visit finder_path('government/policies/benefits-reform', parent: 'ministry-of-magic')
end

Given(/^an organisation finder exists but a bad breadcrumb path is given$/) do
  content_store_has_government_finder
  stub_organisations_registry_request
  stub_rummager_api_request_with_government_results
  stub_people_registry_request

  visit finder_path('government/policies/benefits-reform', parent: 'bernard-cribbins')
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
  expect(page).to have_link("Ministry of Magic", href: "/government/organisations/ministry-of-magic")
  expect(page).to have_css("a[data-track-category='breadcrumbClicked']", text: "Ministry of Magic")
  expect(page).to have_css("a[data-track-action='3']", text: "Ministry of Magic")
  expect(page).to have_css("a[data-track-label='/government/organisations/ministry-of-magic']", text: "Ministry of Magic")
  expect(page).to have_css("a[data-track-options='{\"dimension28\":\"4\",\"dimension29\":\"Ministry of Magic\"}']", text: "Ministry of Magic")
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
  stub_rummager_with_query_validation_request
  visit_cma_cases_finder
end

When(/^I use a checkbox filter$/) do
  find("label", text: "Show open cases").click
  click_on "Filter results"
end

Then(/^I only see documents that match the checkbox filter$/) do
  expect(page).to have_content("1 case")
  expect(page).to have_css('.facet-tags__preposition', text: "That Is")
  expect(page).to have_css('.facet-tag__text', text: "Open")

  within ".filtered-results .document:nth-child(1)" do
    expect(page).to have_content("Big Beer Co / Salty Snacks Ltd merger inquiry")
    expect(page).to_not have_content("Bakery market investigation")
  end
end

Then(/^The checkbox has the correct tracking data$/) do
  expect(page).to have_css("input[type='checkbox'][data-track-category='filterClicked']")
  expect(page).to have_css("input[type='checkbox'][data-track-action='checkboxFacet']")
  expect(page).to have_css("input[type='checkbox'][data-track-label='Show open cases']")
  expect(page).to have_css("input[type='checkbox'][data-module='track-click']")
end

Then(/^I can sort by:$/) do |table|
  expect(find_all('.js-order-results option').collect(&:text)).to eq(table.raw.flatten)
end

When(/^I sort by most viewed$/) do
  select 'Most viewed', from: 'order'
end

When(/^I sort by A-Z$/) do
  select 'A-Z', from: 'order'
end

When(/^I sort by most relevant$/) do
  select 'Relevance', from: 'Sort by'
end

When(/^I filter the results$/) do
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

  expect(page).to have_css("a[data-track-category='navFinderLinkClicked']")
  expect(page).to have_css("#order", text: "Most viewed")
end

Then(/^I see services in alphabetical order$/) do
  within '.filtered-results .document:nth-child(1)' do
    expect(page).to have_content('Apply for your full broomstick licence')
  end

  within '.filtered-results .document:nth-child(2)' do
    expect(page).to have_content('Register a magical spell')
  end

  expect(page).to have_css("a[data-track-category='navFinderLinkClicked']")
  expect(page).to have_css("#order", text: "A-Z")
end

Then(/^I see most relevant order selected$/) do
  expect(page).to have_select('order', selected: "Relevance")
end

Then(/^I see updated newest order selected$/) do
  expect(page).to have_select('order', selected: "Updated (newest)")
end

Then(/^I see topic order selected$/) do
  expect(page).to have_select('order', selected: "Topic")
end

And(/^I see the facet tag$/) do
  within '.facet-tags' do
    expect(page).to have_button("✕")
    expect(page).to have_content("Open")
    expect(page).to have_css("[data-module='remove-filter-link']")
    expect(page).to have_css("[aria-label='Remove filter Open']")
  end
end

And(/^I select a taxon$/) do
  select('Taxon_1', from: 'Topic')
end

And(/^I select a Person$/) do
  check('Rufus Scrimgeour')
end

And(/^I select some document types$/) do
  click_on('Document type')
  find('.govuk-label', text: 'Policy papers').click
  find('.govuk-label', text: 'Consultations (closed)').click
end

And(/^I reload the page$/) do
  visit [current_path, page.driver.request.env['QUERY_STRING']].reject(&:blank?).join('?')
end

Then(/^I should see all people in the people facet$/) do
  expect(page).to have_css('input[id^="people-"]', count: 5)
  find('label', text: 'Albus Dumbledore')
  find('label', text: 'Cornelius Fudge')
  find('label', text: 'Harry Potter')
  find('label', text: 'Ron Weasley')
  find('label', text: 'Rufus Scrimgeour')
end

And(/^I should see all organisations in the organisation facet$/) do
  expect(page).to have_css('input[id^="organisations-"]', count: 4)
  find('label', text: 'Department of Mysteries')
  find('label', text: 'Gringots')
  find('label', text: 'Ministry of Magic')
  find('label', text: 'Closed organisation: Death Eaters')
end

Then(/^I should see all world locations in the world location facet$/) do
  expect(page).to have_css('input[id^="world_locations-"]', count: 2)
  find('label', text: 'Azkaban')
  find('label', text: 'Tracy Island')
end

And(/^I select a World Location$/) do
  click_on('World location')
  check('Azkaban')
end

And(/^I click button \"([^\"]*)\" and select facet (.*)$/) do |button, facet|
  click_on(button)
  find('label', text: facet).click
end

When(/^I click the (.*) remove control$/) do |filter|
  expect(page).to have_css(".js-enabled")

  button = page.find("p[class='facet-tag__text']", text: filter).sibling("button[data-module='remove-filter-link']")
  button.click

  expect(page).to_not have_selector("p[class='facet-tag__text']", text: filter)
end

Then(/^The (.*) checkbox in deselected$/) do |checkbox|
  expect(page.find("##{checkbox}", visible: :all)).to_not be_checked
end

And(/^I fill in some keywords$/) do
  stub_all_rummager_api_requests_with_business_finder_results

  fill_in 'Search', with: "Keyword1 Keyword2\n"
end

Then(/^The keyword textbox is empty$/) do
  expect(page).to have_field('Search', with: '')
end

Then(/^The keyword textbox only contains (.*)$/) do |filter|
  expect(page).to have_field('Search', with: filter)
end

When(/^I use a checkbox filter and another disallowed filter$/) do
  find("label", text: "Show open cases").click
  fill_in("closed_date[from]", with: "1st November 2015")
  stub_rummager_with_cma_cases_for_supergroups_checkbox_and_date
  click_on "Filter results"
end

Then(/^I can sign up to email alerts for allowed filters$/) do
  email_alert_api_has_subscriber_list(
    "tags" => { "case_state" => { any: { "0" => "open" } }, "format" => { any: { "0" => "cma_case" } } },
    'subscription_url' => 'http://www.rathergood.com'
  )

  signup_content_item = cma_cases_with_multi_facets_signup_content_item
  signup_content_item['details']['email_filter_facets'] = [{ 'facet_id' => 'case_state', 'facet_name' => 'case_state' }]

  content_store_has_item('/cma-cases/email-signup', signup_content_item)

  click_link('Get email alerts')

  begin
    click_on('Create subscription')
  rescue ActionController::RoutingError
    expect(page.status_code).to eq(302)
    expect(page.response_headers['Location']).to eql('http://www.rathergood.com')
  end
end

Then("I should see results in the default group") do
  within("#js-results .filtered-results__group") do
    expect(page).to have_css("h2.filtered-results__facet-heading", text: "All businesses")
    expect(page.all("li.document").size).to eq(9) # 9 results in fixture
  end
end

Then("I should see results for scoped by the selected document type") do
  within("#js-results") do
    expect(page.all("li.document").size).to eq(3) # 3 results in fixture
    expect(page).to have_link('Restrictions on usage of spells within school grounds')
    expect(page).to have_link('New platform at Hogwarts for the express train')
    expect(page).to have_link('Installation of double glazing at Hogwarts')

    expect(page).to have_no_link('Proposed changes to magic tournaments')
  end
end

Then("I see results grouped by primary facet value") do
  within("#js-results") do
    expect(page.all(".filtered-results__group").size).to eq(2)

    within(".filtered-results__group:nth-child(1)") do
      expect(page).to have_css("h2.filtered-results__facet-heading", text: "Aerospace")
    end

    within(".filtered-results__group:nth-child(2)") do
      expect(page).to have_css("h2.filtered-results__facet-heading", text: "All businesses")
    end
  end
end

Then("I see results with pinned items") do
  within("#js-results") do
    expect(page.all(".document-heading--pinned").length).to eq(1)
  end
end

Then("I do not see results with pinned items") do
  within("#js-results") do
    expect(page.all(".document-heading--pinned").length).to eq(0)
  end
end

And(/^I press (tab) key to navigate$/) do |key|
  find_field('Search').send_keys key.to_sym
end

Then(/^I should (see|not see) a "Skip to results" link$/) do |can_be_seen|
  visibility = can_be_seen == 'see'
  expect(page).to have_css('[href="#js-results"]', visible: visibility)
end

Then(/^the page has results region$/) do
  expect(page).to have_css('[id="js-results"]')
end

Then(/^the page has a landmark to the search results$/) do
  expect(page).to have_css('[class="column-two-thirds"][role="region"][aria-label$="search results"]')
end

Then(/^the page has a landmark to the search filters$/) do
  expect(page).to have_css('.column-third[role="search"][aria-label]')
end
