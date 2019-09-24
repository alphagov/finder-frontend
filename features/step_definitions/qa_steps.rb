Given /^a QA finder exists/ do
  stub_qa_config
  content_store_has_qa_finder
  stub_rummager_api_request_with_qa_finder_results
end

When /^I visit the QA page/ do
  visit qa_path
end

Then /^I should see the first question/ do
  expect(page).to have_content(first_question)
end

Given /^I am on a single answer question with custom options/ do
  question = get_question_with_custom_options
  page_number = get_page_number(question)
  visit "#{qa_path}?page=#{page_number}"
  expect(page).to have_content(question)
end

Given /^I am answering a (.*?) answer question/ do |type|
  question = get_question_by_type(type)
  page_number = get_page_number(question)
  visit "#{qa_path}?page=#{page_number}"
  expect(page).to have_content(question)
end

Then /^I should see a collection of radio buttons/ do
  expect(page).to have_css(".govuk-radios")
end

When /^I select (.*?) radio button/ do |_amount|
  button = find(:radio_button, checked: false, match: :first)
  button.set(true)
  @radio_params = "#{button[:name]}=#{button[:value]}"
end

Then /^I should see a collection of checkboxes/ do
  expect(page).to have_css(".govuk-checkboxes")
end

When /^I select multiple checkboxes/ do
  @checkbox_params ||= ""
  checkboxes = find_all(:checkbox, visible: true)
  checkboxes.each do |ch|
    ch.check
    @checkbox_params << "#{ch[:name]}=#{ch[:value]}&"
  end
end

When /^I select skip this question/ do
  click_on "Skip this question"
end

When /^I submit my answer/ do
  click_button "Next"
end

Then /^no options are persisted/ do
  params = current_url.split("?")[1]
  expect(params).to eq("page=2")
end

Then /^my options are persisted as url params/ do
  params = Array(@radio_params&.split("&")) + Array(@checkbox_params&.split("&"))
  params.each { |param| expect(current_url).to include(param) }
end

Given /^I am answering the final question/ do
  stub_taxonomy_api_request
  stub_last_page_url
  page_number = facets.length
  visit "#{qa_path}?page=#{page_number}"
end

Then /^I am redirected to the finder results page/ do
  finder_url = mock_qa_config["finder_base_path"] + "?"
  expect(current_url).to match(finder_url)
end

When /^I visit the business finder Q&A/ do
  stub_taxonomy_api_request
  content_store_has_business_finder_qa
  content_store_has_business_readiness_finder
  stub_rummager_api_request_with_filtered_business_readiness_results(
    "filter_any_facet_values[0]" => "24fd50fa-6619-46ca-96cd-8ce90fa076ce",
    "filter_any_facet_values[1]" => "a55f04df-3877-4c73-bbfe-ad7339cdfccf",
  )
  qa_url = business_readiness_qa_config["base_path"]
  visit qa_url
end

When /^I select choice "(.+)"/ do |label|
  find("label", text: label).click
end

When /^I choose 'Yes' and select choice "(.+)"/ do |label|
  choose "Yes", allow_label_click: true
  find("label", text: label).click
end

When /^I skip the rest of the questions/ do
  5.times do
    click_on "Skip this question"
  end
end

Then /^I should be on the business finder page/ do
  expect(page.current_path).to eq "/find-eu-exit-guidance-business"
end

Then /^the correct facets have been pre-selected/ do
  %w(aerospace products-or-goods).each do |value|
    expect(find("input[value=#{value}]", visible: false).checked?).to eq(true)
  end
end
