Given(/^a collection of documents exist$/) do
  content_store_has_mosw_reports_finder
  stub_search_api_request
  stub_taxonomy_api_request
end

Given(/^no results$/) do
  content_store_has_mosw_reports_finder_with_no_facets
  stub_search_api_request_with_no_results
  stub_taxonomy_api_request
end

When(/^I view the finder with no keywords and no facets$/) do
  visit finder_path("mosw-reports")
end

And(/there is not a zero results message$/) do
  expect(page).to_not have_content("no matching results")
end

And(/the page title is updated$/) do
  expect(page).to have_title "#{@keyword_search} - Ministry of Silly Walks reports - GOV.UK"
end

Then(/^I can get a list of all documents with matching metadata$/) do
  visit finder_path("mosw-reports")

  expect(page).to have_content("2 reports")
  expect(page).to have_css(".finder-results .gem-c-document-list__item", count: 2)
  expect(page).to have_css(".gem-c-metadata")

  within ".finder-results .gem-c-document-list__item:nth-child(1)" do
    expect(page).to have_link(
      "West London wobbley walk",
      href: "/mosw-reports/west-london-wobbley-walk",
    )
    expect(page).to have_content("30 December 2003")
    expect(page).to have_content("Backward")
  end

  visit_filtered_finder("walk_type" => "hopscotch")

  expect(page).to have_content("1 report")
  expect(page).to have_css(".finder-results .gem-c-document-list__item", count: 1)
end

And(/there should not be an alert$/) do
  expect {
    page.driver.browser.switch_to.alert.accept
  }.to raise_error(Selenium::WebDriver::Error::NoSuchAlertError)
end

And("I see email and feed sign up links") do
  expect(page).to have_css('a[href="/search/news-and-communications/email-signup"]')
  expect(page).to have_css('a[href="/search/news-and-communications.atom"]')
end

And("I see only one email and feed sign up link on mobile") do
  width = page.driver.browser.manage.window.size.width
  height = page.driver.browser.manage.window.size.height
  page.driver.browser.manage.window.resize_to(375, 812)
  expect(page).to have_css('a[href="/search/news-and-communications/email-signup"]', count: 1)
  expect(page).to have_css('a[href="/search/news-and-communications.atom"]', count: 1)
  page.driver.browser.manage.window.resize_to(width, height)
end

And("I see email and feed sign up links with filters applied") do
  expect(page).to have_css('a[href="/search/news-and-communications/email-signup?people%5B%5D=rufus-scrimgeour"]')
  expect(page).to have_css('a[href="/search/news-and-communications.atom?people%5B%5D=rufus-scrimgeour"]')
end

And("I see email and feed sign up links with filters and order applied") do
  expect(page).to have_css('a[href="/search/news-and-communications/email-signup?people%5B%5D=rufus-scrimgeour&order=updated-newest"]')
  expect(page).to have_css('a[href="/search/news-and-communications.atom?people%5B%5D=rufus-scrimgeour&order=updated-newest"]')
end

When(/^I view a list of news and communications$/) do
  topic_taxonomy_has_taxons
  content_store_has_news_and_communications_finder
  stub_world_locations_api_request
  stub_people_registry_request
  stub_roles_registry_request
  stub_organisations_registry_request
  stub_topical_events_registry_request
  stub_search_api_request_with_news_and_communication_results
  visit finder_path("search/news-and-communications-temp")
end

When(/^I view the news and communications finder$/) do
  stub_taxonomy_api_request
  content_store_has_news_and_communications_finder
  stub_world_locations_api_request
  stub_all_search_api_requests_with_news_and_communication_results
  stub_people_registry_request
  stub_roles_registry_request
  stub_organisations_registry_request
  stub_topical_events_registry_request
  visit finder_path("search/news-and-communications-temp")
end

When(/^I view the policy papers and consultations finder$/) do
  topic_taxonomy_has_taxons
  content_store_has_policy_and_engagement_finder
  stub_organisations_registry_request
  stub_topical_events_registry_request
  stub_world_locations_api_request
  stub_search_api_request_with_policy_papers_results
  stub_search_api_request_with_filtered_policy_papers_results

  visit finder_path("search/policy-papers-and-consultations-temp")
end

When(/^I view the research and statistics finder$/) do
  topic_taxonomy_has_taxons
  content_store_has_statistics_finder
  stub_organisations_registry_request
  stub_manuals_registry_request
  stub_world_locations_api_request
  stub_search_api_request_with_research_and_statistics_results
  stub_search_api_request_with_statistics_results
  stub_search_api_request_with_filtered_research_and_statistics_results
  visit finder_path("search/research-and-statistics-temp")
end

When(/^I view the research and statistics finder with a topic param set$/) do
  topic_taxonomy_has_taxons([
    FactoryBot.build(
      :level_one_taxon_hash,
      content_id: "c58fdadd-7743-46d6-9629-90bb3ccc4ef0",
      title: "Education, training and skills",
    ),
  ])
  content_store_has_statistics_finder
  stub_organisations_registry_request
  stub_manuals_registry_request
  stub_world_locations_api_request
  stub_search_api_request_with_research_and_statistics_results
  stub_search_api_request_with_statistics_results
  stub_search_api_request_with_filtered_research_and_statistics_results
  visit finder_path("search/research-and-statistics-temp", topic: "c58fdadd-7743-46d6-9629-90bb3ccc4ef0")
end

When(/^I view the aaib reports finder with a topic param set$/) do
  topic_taxonomy_has_taxons([
    FactoryBot.build(
      :level_one_taxon_hash,
      content_id: "c58fdadd-7743-46d6-9629-90bb3ccc4ef0",
      title: "Education, training and skills",
    ),
  ])
  content_store_has_aaib_reports_finder
  stub_organisations_registry_request
  stub_manuals_registry_request
  stub_world_locations_api_request
  stub_search_api_request_with_aaib_reports_results
  visit finder_path("aaib-reports-temp", topic: "c58fdadd-7743-46d6-9629-90bb3ccc4ef0")
end

When(/^I view a list of services$/) do
  topic_taxonomy_has_taxons
  content_store_has_services_finder
  stub_search_api_request_with_services_results
  stub_people_registry_request
  stub_organisations_registry_request

  visit finder_path("search/services-temp")
end

When(/^I search documents by keyword: "(.*)"$/) do |term|
  stub_keyword_search_api_request(term)

  visit finder_path("mosw-reports")

  @keyword_search = term

  within ".filter-form" do
    fill_in("Search", with: @keyword_search)
    click_on("Search")
  end
end

Then(/^I see all documents which contain the keywords$/) do
  within ".filtered-results" do
    expect(page).to have_css("a", text: @keyword_search)
  end
end

When(/^I visit a finder by keyword with q parameter$/) do
  stub_keyword_search_api_request(@keyword_search)

  visit finder_path("mosw-reports", q: @keyword_search)
end

Given(/^a government finder exists$/) do
  stub_taxonomy_api_request
  content_store_has_government_finder
  stub_search_api_request_with_government_results
  stub_organisations_registry_request
end

Then(/^I should see a blue banner$/) do
  expect(page).to have_css(".gem-c-inverse-header")
  expect(page).to have_content("Education, training and skills")
  expect(page).to_not have_css(".app-taxonomy-select")
end

Then(/^I can see documents which are marked as being in history mode$/) do
  visit finder_path("government/policies/benefits-reform")
  expect(page).to have_css(".published-by", count: 5)
  expect(page).to have_content("2005 to 2010 Labour government")
end

Then(/^I see the atom feed$/) do
  expect(page).to have_selector("id", text: "tag:www.dev.gov.uk,2005:/restrictions-on-usage-of-spells-within-school-grounds")
  expect(page).to have_selector("updated", text: "2017-12-30T10:00:00+00:00")
  expect(page).to have_selector(:css, 'link[href="http://www.dev.gov.uk/restrictions-on-usage-of-spells-within-school-grounds"]')
  expect(page).to have_selector("title", text: "Restrictions on usage of spells within school grounds")
  expect(page).to have_selector("summary", text: "Restrictions on usage of spells within school grounds")
end

Given(/^a collection of documents with bad metadata exist$/) do
  stub_taxonomy_api_request
  content_store_has_mosw_reports_finder
  stub_search_api_request_with_bad_data
end

Then(/^I can get a list of all documents with good metadata$/) do
  visit finder_path("mosw-reports")
  expect(page).to have_css(".finder-results .gem-c-document-list__item", count: 2)

  within ".finder-results .gem-c-document-list__item:nth-child(1)" do
    expect(page).to have_content("Backward")
    expect(page).not_to have_content("England")
  end

  within ".finder-results .gem-c-document-list__item:nth-child(2)" do
    expect(page).to have_content("Northern Ireland")
    expect(page).not_to have_content("Hopscotch")
  end
end

Given(/^a finder tagged to the topic taxonomy$/) do
  stub_taxonomy_api_request
  stub_content_store_with_a_taxon_tagged_finder
  stub_rummager_with_cma_cases
end

Given(/^a collection of documents that can be filtered by dates$/) do
  stub_taxonomy_api_request
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
  stub_taxonomy_api_request
  content_store_has_mosw_reports_finder
  stub_search_api_request
end

Then(/^I can see filters based on the results$/) do
  visit finder_path("mosw-reports")

  within first(".gem-c-option-select") do
    expect(page).to have_selector("input#walk_type-backward")
    expect(page).to have_content("Hopscotch")
    expect(page).to_not have_selector("input#organisations-ministry-of-silly-walks")
  end
end

And(/^filters are wrapped in a progressive disclosure element$/) do
  expect(page).to have_selector("#facet-wrapper")
end

And(/^filters are not wrapped in a progressive disclosure element$/) do
  expect(page).not_to have_selector("#facet-wrapper")
end

Given(/^a finder with paginated results exists$/) do
  stub_taxonomy_api_request
  content_store_has_government_finder_with_10_items
  stub_search_api_request_with_10_government_results
  stub_search_api_request_with_query_param_no_results("xxxxxxxxxxxxxxYYYYYYYYYYYxxxxxxxxxxxxxxx")
end

Then(/^I can see pagination$/) do
  visit finder_path("government/policies/benefits-reform")

  expect(page).not_to have_content("Previous page")
  expect(page).to have_content("Next page")
end

Then(/^I can browse to the next page$/) do
  stub_search_api_request_with_10_government_results_page_2
  visit finder_path("government/policies/benefits-reform", page: 2)

  expect(page).to have_content("Previous page")
  expect(page).not_to have_content("Next page")
end

Then(/^I browse to a huge page number and get an appropriate error$/) do
  stub_search_api_request_with_422_response(999_999)
  visit finder_path("government/policies/benefits-reform", page: 999_999)

  expect(page.status_code).to eq(422)
end

And("I click on the atom feed link") do
  within("#subscription-links-footer") do
    click_on "Subscribe to feed"
  end
end

And("there is machine readable information") do
  schema_sections = page.find_all("script[type='application/ld+json']", visible: :hidden)
  schemas = schema_sections.map { |section| JSON.parse(section.text(:all)) }

  org_schema = schemas.detect { |schema| schema["@type"] == "SearchResultsPage" }
  expect(org_schema["name"]).to_not be_nil

  tag = "link[rel='canonical']"
  expect(page).to have_css(tag, visible: :hidden)
end

Then(/^I can see that Google won't index the page$/) do
  tag = "meta[name='robots'][content='noindex']"
  expect(page).to have_css(tag, visible: :hidden)
end

Then(/^I can see that Google can index the page$/) do
  tag = "meta[name='robots'][content='noindex']"
  expect(page).not_to have_css(tag, visible: :hidden)
end

Given(/^a finder with description exists$/) do
  stub_taxonomy_api_request
  stub_content_store_with_cma_cases_finder_with_description
  stub_rummager_with_cma_cases
end

Given(/^a finder with a no_index property exists$/) do
  stub_taxonomy_api_request
  stub_content_store_with_cma_cases_finder_with_no_index
  stub_rummager_with_cma_cases
end

Given(/^a finder with metadata exists$/) do
  stub_taxonomy_api_request
  stub_content_store_with_cma_cases_finder_with_metadata
  stub_rummager_with_cma_cases
end

When(/^I can see that the finder metadata is present$/) do
  visit "/cma-cases-temp"

  expect(page).to have_css(".gem-c-metadata")
  expect(page).to_not have_css(".gem-c-metadata.gem-c-metadata--inverse")
end

When(/^I can see that the finder metadata is present and inverted$/) do
  expect(page).to have_css(".gem-c-metadata")
  expect(page).to have_css(".gem-c-metadata.gem-c-metadata--inverse")
end

And(/^the breadcrumbs are outside the main container$/) do
  expect(page).to have_selector(".app-before-content .gem-c-breadcrumbs")
  expect(page).not_to have_selector("#main .gem-c-breadcrumbs")
end

When(/^I can see that the description in the metadata is present$/) do
  visit "/cma-cases-temp"

  desc_text = "Find reports and updates on current and historical CMA investigations"
  desc_tag = "meta[name='description'][content='#{desc_text}']"
  expect(page).to have_css(desc_tag, visible: :hidden)
end

When(/^I can see that the noindex tag is is present in the metadata$/) do
  visit "/cma-cases-temp"

  noindex_tag = "meta[name='robots'][content='noindex']"
  expect(page).to have_css(noindex_tag, visible: :hidden)
end

Given(/^an organisation finder exists$/) do
  stub_taxonomy_api_request
  content_store_has_government_finder
  stub_search_api_request_with_government_results
  stub_organisations_registry_request
  stub_people_registry_request
  stub_taxonomy_api_request

  visit finder_path("government/policies/benefits-reform", parent: "ministry-of-magic")
end

Given(/^an organisation finder exists but a bad breadcrumb path is given$/) do
  stub_taxonomy_api_request
  content_store_has_government_finder
  stub_search_api_request_with_government_results
  stub_organisations_registry_request
  stub_people_registry_request
  stub_taxonomy_api_request

  visit finder_path("government/policies/benefits-reform", parent: "bernard-cribbins")
end

Then(/^I can see a breadcrumb for home$/) do
  expect(page).to have_link("Home", href: "/")
end

Then(/^I can see a breadcrumb for all organisations$/) do
  expect(page).to have_link("Organisations", href: "/government/organisations")
end

And(/^no breadcrumb for all organisations$/) do
  expect(page).to_not have_link("Organisations", href: "/government/organisations")
end

Then(/^I can see a breadcrumb for the organisation$/) do
  expect(page).to have_link("Ministry of Magic", href: "/government/organisations/ministry-of-magic")
end

Then(/^I can see taxonomy breadcrumbs$/) do
  visit finder_path("cma-cases-temp")
  expect(page).to have_selector(".govuk-breadcrumbs--collapse-on-mobile")
  expect(page).to have_selector(".govuk-breadcrumbs__list-item", text: "Competition Act and cartels")
  expect(page.find_all(".govuk-breadcrumbs__list-item").count).to eql(2)
end

Given(/^a collection of documents exist that can be filtered by checkbox$/) do
  stub_taxonomy_api_request
  stub_content_store_with_cma_cases_finder_for_supergroup_checkbox_filter
  stub_rummager_with_cma_cases_for_supergroups_checkbox
  visit_cma_cases_finder
end

When(/^I use a checkbox filter$/) do
  find("label", text: "Show open cases").click
  within ".js-live-search-fallback" do
    click_on "Filter results"
  end
end

Then(/^I only see documents that match the checkbox filter$/) do
  expect(page).to have_content("1 case")
  expect(page).to have_css(".facet-tags__preposition", text: "That Is")
  expect(page).to have_css(".facet-tag__text", text: "Open")

  within ".finder-results .gem-c-document-list__item:nth-child(1)" do
    expect(page).to have_content("Big Beer Co / Salty Snacks Ltd merger inquiry")
    expect(page).to_not have_content("Bakery market investigation")
  end
end

Then(/^I can sort by:$/) do |table|
  expect(find_all(".js-order-results option").collect(&:text)).to eq(table.raw.flatten)
end

When(/^I sort by most viewed$/) do
  select "Most viewed", from: "order"
end

When(/^I sort by A-Z$/) do
  select "A-Z", from: "order"
end

When(/^I sort by most relevant$/) do
  select "Relevance", from: "Sort by"
end

When(/^I filter the results$/) do
  within ".js-live-search-fallback" do
    click_on "Filter results"
  end
end

Then(/^I see the most viewed articles first$/) do
  within ".finder-results .gem-c-document-list__item:nth-child(1)" do
    expect(page).to have_content("Press release from Hogwarts")
    expect(page).to have_content("25 December 2017")
  end

  within ".finder-results .gem-c-document-list__item:nth-child(2)" do
    expect(page).to have_content("16 November 2018")
  end

  expect(page).to have_css("#order", text: "Most viewed")
end

Then(/^I see services in alphabetical order$/) do
  within ".finder-results .gem-c-document-list__item:nth-child(1)" do
    expect(page).to have_content("Apply for your full broomstick licence")
  end

  within ".finder-results .gem-c-document-list__item:nth-child(2)" do
    expect(page).to have_content("Register a magical spell")
  end

  expect(page).to have_css("#order", text: "A-Z")
end

Then(/^I see (.*) order selected$/) do |label|
  expect(page).to have_select("order", selected: label)
end

And(/^I see the facet tag$/) do
  within first ".facet-tags" do
    expect(page).to have_button("✕")
    expect(page).to have_content("Open")
    expect(page).to have_css("[data-module='remove-filter-link']")
    expect(page).to have_css("[aria-label='Remove filter Open']")
  end
end

And(/^I select a Person$/) do
  check("Rufus Scrimgeour")
end

And(/^I select some document types$/) do
  click_on("Document type")
  find(".govuk-checkboxes__item .govuk-label", text: "Policy papers").click
  find(".govuk-checkboxes__item .govuk-label", text: "Consultations (closed)").click
end

And(/^I select upcoming statistics$/) do
  find(".govuk-label", text: "Statistics (upcoming)").click
end

And(/^I select published statistics$/) do
  find(".govuk-label", text: "Statistics (published)").click
end

And(/^I click filter results$/) do
  within ".js-live-search-fallback" do
    click_on "Filter results"
  end
end

And(/^I reload the page$/) do
  visit [current_path, page.driver.request.env["QUERY_STRING"]].reject(&:blank?).join("?")
end

Then(/^I should see all people in the people facet$/) do
  expect(page).to have_css('input[id^="people-"]', count: 5)
  find("label", text: "Albus Dumbledore")
  find("label", text: "Cornelius Fudge")
  find("label", text: "Harry Potter")
  find("label", text: "Ron Weasley")
  find("label", text: "Rufus Scrimgeour")
end

And(/^I should see all organisations in the organisation facet$/) do
  expect(page).to have_css('input[id^="organisations-"]', count: 4)
  find("label", text: "Department of Mysteries")
  find("label", text: "Gringots")
  find("label", text: "Ministry of Magic")
  find("label", text: "Closed organisation: Death Eaters")
end

Then(/^I should see all world locations in the world location facet$/) do
  expect(page).to have_css('input[id^="world_locations-"]', count: 2)
  find("label", text: "Azkaban")
  find("label", text: "Tracy Island")
end

And(/^I click button "([^"]*)" and select facet (.*)$/) do |button, facet|
  click_on(button)
  find("label", text: facet).click
end

When(/^I click the (.*) remove control$/) do |filter|
  expect(page).to have_css(".govuk-frontend-supported")

  button = page.find("span[class='facet-tag__text']", text: filter).sibling("button[data-module='remove-filter-link']")
  button.click

  expect(page).to_not have_selector("span[class='facet-tag__text']", text: filter)
end

Then(/^The (.*) checkbox in deselected$/) do |checkbox|
  expect(page.find("##{checkbox}", visible: :all)).to_not be_checked
end

And(/^I fill in some keywords$/) do
  fill_in "Search", with: "Keyword1 Keyword2\n"
end

When(/^I use a checkbox filter and another disallowed filter$/) do
  find("label", text: "Show open cases").click
  fill_in("closed_date[from]", with: "1st November 2015")
  stub_rummager_with_cma_cases_for_supergroups_checkbox_and_date
  within ".js-live-search-fallback" do
    click_on "Filter results"
  end
end

When("I do not select any of the filters on the signup page") do
  step("I use a checkbox filter")
  stub_content_store_has_item("/cma-cases/email-signup", cma_cases_with_multi_facets_signup_content_item)

  within "#subscription-links-footer" do
    click_link("Get emails")
  end

  click_on("Continue")
end

Then(/^I can sign up to email alerts for allowed filters$/) do
  stub_email_alert_api_creates_subscriber_list(
    "tags" => {
      "case_type" => { any: %w[competition-disqualification] },
      "case_state" => { any: %w[open closed] },
    },
    "subscription_url" => "http://www.rathergood.com",
  )

  stub_content_store_has_item("/cma-cases/email-signup", cma_cases_with_multi_facets_signup_content_item)

  within "#subscription-links-footer" do
    click_link("Get emails")
  end

  check("Closed")
  check("Competition disqualification")

  click_on("Continue")
  expect(page).to have_current_path("/email/subscriptions/new", ignore_query: true)
end

Then("I see an error about selecting at least one option") do
  expect(page).to have_content("Select at least one option")
end

Then("I should see results for scoped by the selected document type") do
  expect(page).to have_text("3 results")
  within("#js-results") do
    expect(page.all(".gem-c-document-list__item").size).to eq(3) # 3 results in fixture
    expect(page).to have_link("Restrictions on usage of spells within school grounds")
    expect(page).to have_link("New platform at Hogwarts for the express train")
    expect(page).to have_link("Installation of double glazing at Hogwarts")

    expect(page).to have_no_link("Proposed changes to magic tournaments")
  end
end

Then("I should see all research and statistics") do
  expect(page).to have_text("3 results")
  within("#js-results") do
    expect(page.all(".gem-c-document-list__item").size).to eq(3)
    expect(page).to have_link("Restrictions on usage of spells within school grounds")
    expect(page).to have_link("New platform at Hogwarts for the express train")
    expect(page).to have_link("Installation of double glazing at Hogwarts")
    expect(page).to have_no_link("Proposed changes to magic tournaments")
  end
end

Then("I should see upcoming statistics") do
  expect(page).to have_text("1 result")
  within("#js-results") do
    expect(page.all(".gem-c-document-list__item").size).to eq(1)
    expect(page).to have_link("Restrictions on usage of spells within school grounds")
    expect(page).to have_no_link("New platform at Hogwarts for the express train")
    expect(page).to have_no_link("Installation of double glazing at Hogwarts")
    expect(page).to have_no_link("Proposed changes to magic tournaments")
  end
end

And(/^I press (tab) key to navigate$/) do |key|
  find_field("Search").send_keys key.to_sym
end

Then(/^I should (see|not see) a "Skip to results" link$/) do |can_be_seen|
  visibility = can_be_seen == "see"
  expect(page).to have_css('[href="#js-results"]', visible: visibility)
end

Then(/^the page has results region$/) do
  expect(page).to have_css('[id="js-results"]')
end

Then(/^the page has a landmark to the search results$/) do
  expect(page).to have_css('[class="govuk-grid-column-two-thirds js-live-search-results-block filtered-results"][role="region"][aria-label$="search results"]')
end

And(/^I should not see an upcoming statistics facet tag$/) do
  expect(page).to_not have_css("span.facet-tag__text", text: "Upcoming statistics")
end
