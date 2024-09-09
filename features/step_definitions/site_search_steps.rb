When(/^I search all content for "([^"]*)"$/) do |search_term|
  visit "/search/all?q=#{search_term}"
end

Then("I can see results for my search") do
  expect(page).to have_link("West London wobbley walk")
  expect(page).to have_link("The Gerry Anderson")
end
