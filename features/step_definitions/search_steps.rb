Given(/^the search page exists$/) do
  stub_content_store_has_item("/search", schema: "special_route")
end

When(/^I search for "([^"]*)" from "(.*)" on the legacy json endpoint$/) do |search_term, organisation|
  visit "/search.json?q=#{search_term}&filter_organisations[]=#{organisation}"
end

Given(/^the all content finder exists$/) do
  topic_taxonomy_has_taxons([
    FactoryBot.build(
      :level_one_taxon_hash,
      content_id: "131313",
      title: "Music",
      child_taxons: [
        FactoryBot.build(:taxon_hash, content_id: "1989", title: "Best songs"),
      ],
    ),
  ])
  content_store_has_all_content_finder
  stub_topical_events_api_request
  stub_world_locations_api_request
  stub_organisations_registry_request
  stub_manuals_registry_request

  stub_search_api_request_with_organisation_filter_all_content_results
  stub_search_api_request_with_manual_filter_all_content_results
  stub_search_api_request_with_misspelt_query
  stub_search_api_request_with_html_chars_query
  stub_search_api_request_with_query
  stub_search_api_request_with_sorted_query
  stub_search_api_request_with_filtered_query
end

Then(/^I am redirected to the (html|json) all content finder results page$/) do |format|
  expect(page).to have_current_path(finder_path("search/all"), ignore_query: true)
  expect(page.response_headers["Content-Type"]).to include(format)
end

When(/^I search for "([^"]*)" on the legacy search page$/) do |search_term|
  visit "/search?q=#{search_term}"
end

Then(/^I see a "(.*)" spelling suggestion$/) do |suggestion|
  expect(page).to have_link suggestion.to_s, href: %r{/search/all\?keywords=#{suggestion}}
end
