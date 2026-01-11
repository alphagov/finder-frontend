When(/^I search all content for "([^"]*)"$/) do |search_term|
  visit "/search/all?q=#{search_term}"
end

When(/^I search all content with a parent for "([^"]*)"$/) do |search_term|
  visit "/search/all?parent=ministry-of-magic&organisations[]=ministry-of-magic&q=#{search_term}"
end

When(/^I search for "([^"]*)" with a hidden clearable manual filter$/) do |search_term|
  visit "/search/all?q=#{search_term}&manual%5B%5D=how-to-be-a-wizard"
end

When(/^I change my search term to "([^"]*)" and submit$/) do |search_term|
  fill_in "Search", with: search_term
  click_on "Search"
end

Then("I can see results for my search") do
  expect(page).to have_link("West London wobbley walk")
  expect(page).to have_link("The Gerry Anderson")
end

Then("I can see how many results there are") do
  expect(page).to have_selector("h2", text: "2 results")
end

Then(/^the GA4 ecommerce tracking tags are present$/) do
  container = page.find("#app-all-content-finder[data-ga4-ecommerce]")
  expect(container["data-ga4-ecommerce-start-index"]).to eq("1")
  expect(container["data-ga4-list-title"]).to eq("Search")
  expect(container["data-ga4-search-query"]).to eq("how to walk silly")
  expect(container["data-ga4-ecommerce-variant"]).to eq("Relevance")

  first_result = page.first("a[data-ga4-ecommerce-row]")
  expect(first_result["data-ga4-ecommerce-path"]).to eq("/mosw-reports/west-london-wobbley-walk")
end

Then("my search is still filtered by manual") do
  expect(page).to have_link("Remove filter Manual: How to be a Wizard", normalize_ws: true)
end

When("I open the filter panel") do
  click_on "Filter and sort"
end

When(/^I open the "([^"]*)" filter section$/) do |title|
  # Capybara #click can't deal with <details> elements, so need to manually find summary first
  section = find("details summary", text: title)
  section.click
end

When(/^I select the "([^"]*)" option$/) do |option|
  choose option
end

When(/^I check the "([^"]*)" option$/) do |option|
  check option, allow_label_click: true
end

When(/^I select "([^"]*)" as the (\S+)$/) do |item, from|
  select item, from:
end

When(/^I enter "([^"]*)" for "([^"]*)" under "([^"]*)"$/) do |text, field, fieldset|
  within_fieldset(fieldset) do
    fill_in field, with: text
  end
end

When(/I click on the "([^"]*)" filter tag/) do |filter|
  click_on filter
end

Then(/the "([^"]*)" filter has been removed/) do |filter|
  expect(page).not_to have_link(filter)
end

Then("I can see filtered results") do
  expect(page).to have_link("Death by a thousand cuts")
end

When("I apply the filters") do
  click_on "Apply"
end

Then("I can see a filter section for every visible facet on the all content finder") do
  # These are visible filter types and should have a section
  expect(page).to have_selector("h2", text: "Sort by")
  expect(page).to have_selector("h2", text: "Filter by Topic")
  expect(page).to have_selector("h2", text: "Filter by Type")
  expect(page).to have_selector("h2", text: "Filter by Date")

  # These are hidden clearable filters and should not have a section
  expect(page).not_to have_selector("h2", text: "Filter by Organisation")
  expect(page).not_to have_selector("h2", text: "Filter by World location")
  expect(page).not_to have_selector("h2", text: "Filter by Topical event")
end

Then("I can see sorted results") do
  expect(page).to have_link("Loving him was red")
end

Then("the filter panel shows status text for each section") do
  click_on "Filter and sort"

  within(".app-c-filter-panel") do
    expect(page).to have_selector("summary", text: "Filter by Topic 2 selected", normalize_ws: true)
    expect(page).to have_selector("summary", text: "Filter by Type 2 selected", normalize_ws: true)
    expect(page).to have_selector("summary", text: "Filter by Date 2 selected", normalize_ws: true)
  end
end

Then("the filter panel is open by default") do
  expect(page).to have_selector("button[aria-expanded='true']", text: "Filter and sort")
end

Then(/^I can see an error message "([^"]*)"$/) do |text|
  expect(page).to have_selector(".govuk-error-message", text:, visible: :visible)
end
