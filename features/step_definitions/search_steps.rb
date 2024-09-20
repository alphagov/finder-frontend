Given(/^the search page exists$/) do
  stub_content_store_has_item("/search", schema: "special_route")
end

When(/^I search for an empty string$/) do
  visit "/search?q="
end

When(/^I search for "([^"]*)" from "([^"]*)"$/) do |search_term, organisation|
  visit "/search?q=#{search_term}&filter_organisations[]=#{organisation}"
end

When(/^I search for "([^"]*)" in manual "([^"]*)"$/) do |search_term, manual|
  visit "/search?q=#{search_term}&filter_manual[]=#{manual}"
end

When(/^I search for "([^"]*)" from "(.*)" on the json endpoint$/) do |search_term, organisation|
  visit "/search.json?q=#{search_term}&filter_organisations[]=#{organisation}"
end

Then(/^I am able to set search terms$/) do
  expect(page).to have_field("Search GOV.UK", with: "")
end

Given(/^the all content finder exists$/) do
  topic_taxonomy_has_taxons
  content_store_has_all_content_finder
  stub_topical_events_api_request
  stub_world_locations_api_request
  stub_organisations_registry_request
  stub_manuals_registry_request

  stub_search_api_request_with_organisation_filter_all_content_results
  stub_search_api_request_with_manual_filter_all_content_results
  stub_search_api_request_with_misspelt_query
  stub_search_api_request_with_query
end

Given(/^the new all content finder UI is (\w+)$/) do |state|
  env_value = state == "enabled" ? "true" : nil
  stub_const("ENV", ENV.to_hash.merge("ENABLE_NEW_ALL_CONTENT_FINDER_UI" => env_value))
end

Then(/^I am redirected to the (html|json) all content finder results page$/) do |format|
  expect(page).to have_current_path(finder_path("search/all"), ignore_query: true)
  expect(page.response_headers["Content-Type"]).to include(format)
end

Then(/^results are filtered with a facet tag of (.*)/) do |text|
  expect(page).to have_selector("span[class='facet-tag__text']", text:)
end

When(/^I search for "([^"]*)"$/) do |search_term|
  visit "/search?q=#{search_term}"
end

Then(/^I see a "(.*)" spelling suggestion$/) do |suggestion|
  expect(page).to have_link suggestion.to_s, href: %r{/search/all\?keywords=#{suggestion}}
end
