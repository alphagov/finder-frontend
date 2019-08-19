require "spec_helper"

RSpec.feature "Checklists", type: :feature do
  scenario "User answers questions" do
    given_i_visit_the_checklist_question_and_answer_flow
    and_i_say_that_i_sell_goods
    and_i_say_that_i_am_a_eu_citizen
    then_i_should_see_the_results_page
  end

  def given_i_visit_the_checklist_question_and_answer_flow
    visit '/find-brexit-guidance'
  end

  def and_i_say_that_i_sell_goods
    check "Sell goods or provide services in the UK"
    click_on "Next"
  end

  def and_i_say_that_i_am_a_eu_citizen
    choose "Yes"
    click_on "Next"
  end

  def then_i_should_see_the_results_page
    expect(page).to have_content "This is the actions page"
  end
end
