Then(/^the links on the page have tracking attributes$/) do
  visit finder_path('government/policies/benefits-reform')

  expect(page).to have_selector('ul[data-module="track-click"]')

  document_links = page.all('li.document a')
  expect(document_links.count).to be_positive

  first_link = document_links.first

  expect(first_link['data-track-category']).to eq('navFinderLinkClicked')
  expect(first_link['data-track-action']).to eq('Ministry of Silly Walks reports.1')
  expect(first_link['data-track-label']).to eq(first_link['href'])

  options = JSON.parse(first_link['data-track-options'])

  expect(options['dimension28']).to eq(document_links.count.to_s)
  expect(options['dimension29']).to eq(first_link.text)
end

Then(/^I see an email signup link$/) do
  expect(page).to have_css(".gem-c-subscription-links", text: "Subscribe to email alerts")
  expect(page).to have_css("a[data-track-category='emailAlertLinkClicked']")
  expect(page).to have_css("a[data-track-action='/government/policies/benefits-reform/email-signup']")
  expect(page).to have_css("a[data-track-label='Subscribe to email alerts']")
end
