require "spec_helper"

RSpec.feature "Checklists", type: :feature do
  scenario "User answers questions" do
    given_i_visit_the_checklist_question_and_answer_flow
    and_i_have_a_business
    and_i_say_that_i_sell_goods
    and_i_say_that_i_am_a_eu_citizen
    then_i_should_see_the_results_page
  end

  scenario "User answers conditional questions" do
    given_i_visit_the_checklist_question_and_answer_flow
    and_i_dont_have_a_business
    and_i_say_that_i_am_a_eu_citizen
    then_i_should_see_the_results_page
  end

  def given_i_visit_the_checklist_question_and_answer_flow
    visit '/find-brexit-guidance'
  end

  def and_i_have_a_business
    expect(page).to have_content "Do you own a business?"
    choose "Yes"
    click_on "Next"
  end

  def and_i_dont_have_a_business
    expect(page).to have_content "Do you own a business?"
    choose "No"
    click_on "Next"
  end

  def and_i_say_that_i_sell_goods
    expect(page).to have_content "Does your business do any of the following activities?"
    check "Sell goods or provide services in the UK"
    click_on "Next"
  end

  def and_i_say_that_i_am_a_eu_citizen
    expect(page).to have_content "Are you an EU national living in the UK?"
    choose "Yes"
    click_on "Next"
  end

  def then_i_should_see_the_results_page
    expect(page).to have_content "Actions you may need to do for Brexit"
  end

  def and_i_should_see_the_related_actions
    expect(page).to have_content "Get a new passport"
  end
end
