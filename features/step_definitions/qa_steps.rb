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

Given /^I am answering a (.*?) answer question/ do |type|
  question = get_question_by_type(type)
  page_number = get_page_number(question)
  visit "#{qa_path}?page=#{page_number}"
  expect(page).to have_content(question)
end

Then /^I should see a collection of radio buttons/ do
  expect(page).to have_css('.govuk-radios')
end

When /^I select a radio button/ do
  button = find(:radio_button, checked: false, match: :first)
  button.set(true)
  @radio_params = "#{button[:name]}=#{button[:value]}"
end

Then /^I should see a collection of checkboxes/ do
  expect(page).to have_css('.govuk-checkboxes')
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
  params = current_url.split('?')[1]
  expect(params).to eq('page=2')
end

Then /^my options are persisted as url params/ do
  params = Array(@radio_params&.split('&')) + Array(@checkbox_params&.split('&'))
  params.each { |param| expect(current_url).to include(param) }
end

Given /^I am answering the final question/ do
  stub_last_page_url
  page_number = facets.length
  visit "#{qa_path}?page=#{page_number}"
end

Then /^I am redirected to the finder results page/ do
  finder_url = mock_qa_config['finder_base_path'] + '?'
  expect(current_url).to match(finder_url)
end
