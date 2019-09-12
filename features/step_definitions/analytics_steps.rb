Then(/^the links on the page have tracking attributes$/) do
  visit finder_path("government/policies/benefits-reform")

  expect(page).to have_selector('.finder-results[data-module="track-click"]')

  document_links = page.all(".gem-c-document-list__item-title")
  expect(document_links.count).to be_positive

  first_link = document_links.first

  expect(first_link["data-track-category"]).to eq("navFinderLinkClicked")
  expect(first_link["data-track-action"]).to eq("Ministry of Silly Walks reports.1")
  expect(first_link["data-track-label"]).to eq(first_link["href"])

  options = JSON.parse(first_link["data-track-options"])

  expect(options["dimension28"]).to eq(document_links.count)
  expect(options["dimension29"]).to eq(first_link.text)
end

Then(/^the ecommerce tracking tags are present$/) do
  visit finder_path("search/all", q: "breakfast")

  expect(page).to have_selector("form[data-analytics-ecommerce]")

  form = page.find("form[data-analytics-ecommerce]")
  expect(form["data-ecommerce-start-index"]).to eq("1")
  expect(form["data-list-title"]).to eq("Search")
  expect(form["data-search-query"]).to eq("breakfast")

  results = page.all("a[data-ecommerce-row]")
  expect(results.count).to be_positive

  first_link = results.first

  expect(first_link["data-ecommerce-path"]).to eq("/restrictions-on-usage-of-spells-within-school-grounds")
  expect(first_link["data-ecommerce-content-id"]).to eq("1234")
end

And(/^I search for lunch$/) do
  stub_rummager_api_request_with_query_param_no_results("lunch")

  fill_in "Search", with: "lunch"
end

Then(/^the data-search-query has been updated to (.*)$/) do |query|
  form = page.find("form[data-analytics-ecommerce]")
  expect(form["data-search-query"]).to eq(query)
end
