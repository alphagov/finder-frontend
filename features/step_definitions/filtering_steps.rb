Given(/^a collection of cases exist$/) do
  stub_case_collection_api_request
end

Then(/^I can get a list of all merger inquiries$/) do
  visit finder_path('cma-cases')
  page.should have_content('2 cases')

  within '.results .document:nth-child(1)' do
    page.should have_link('HealthCorp / DrugInc merger inquiry')
    # page.should have_content('30 December 2003')
    # page.should have_content('Merger inquiry')
  end

  within '.results .document:nth-child(2)' do
    page.should have_link('Private healthcare market investigation')
    # page.should have_content('14 August 2007')
    # page.should have_content('Market investigation')
  end

  select_filters('Case type' => 'Merger inquiries')

  page.should have_content('1 case')

  within '.results .document:nth-child(1)' do
    page.should have_link('HealthCorp / DrugInc merger inquiry')
    # page.should have_content('30 December 2003')
    # page.should have_content('Merger inquiry')
  end

  page.should have_no_content('Private healthcare market investigation')
end
