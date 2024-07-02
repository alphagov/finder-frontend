Then(/^the GA4 ecommerce tracking tags are present$/) do
  visit finder_path("search/all", q: "breakfast")

  expect(page).to have_selector(".js-live-search-results-block[data-ga4-ecommerce]")

  form = page.find(".js-live-search-results-block[data-ga4-ecommerce]")
  expect(form["data-ga4-ecommerce-start-index"]).to eq("1")
  expect(form["data-ga4-list-title"]).to eq("Search")
  expect(form["data-ga4-search-query"]).to eq("breakfast")

  results = page.all("a[data-ga4-ecommerce-row]")
  expect(results.count).to be_positive

  first_link = results.first

  expect(first_link["data-ga4-ecommerce-path"]).to eq("/restrictions-on-usage-of-spells-within-school-grounds")
end
