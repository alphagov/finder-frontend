Given(/^a collection of cases exist$/) do
  stub_case_collection_api_request
end

Then(/^I can get a list of all merger inquiries$/) do
  visit finder_path('cma-cases')
  page.should have_content('7 cases')
  select_filters('Case type' => 'Merger inquiries')
  page.should have_content('2 cases')
end
