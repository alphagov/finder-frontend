When(/^I search all content for "([^"]*)"$/) do |search_term|
  visit "/search/all?q=#{search_term}"
end

Then("I can see results for my search") do
  expect(page).to have_link("West London wobbley walk")
  expect(page).to have_link("The Gerry Anderson")
end

Then("I can see how many results there are") do
  expect(page).to have_selector("h2", text: "2 results")
end

When("I open the filter panel") do
  click_on "Filter and sort"
end

Then("I can see a filter section for every visible facet on the all content finder") do
  # These are visible filter types and should have a section
  expect(page).to have_selector("h2", text: "Filter by Topic")
  expect(page).to have_selector("h2", text: "Filter by Type")
  expect(page).to have_selector("h2", text: "Filter by Updated")

  # These are hidden clearable filters and should not have a section
  expect(page).not_to have_selector("h2", text: "Filter by Organisation")
  expect(page).not_to have_selector("h2", text: "Filter by World location")
  expect(page).not_to have_selector("h2", text: "Filter by Topical event")
end
