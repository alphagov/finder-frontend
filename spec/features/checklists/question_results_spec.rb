require "spec_helper"

RSpec.feature "Questions workflow", type: :feature do
  scenario "basic questions" do
    when_i_visit_the_checklist_flow
    and_i_answer_the_basic_questions
    then_i_should_see_the_results_page
    and_i_should_see_a_passport_action
    and_i_should_not_see_an_eori_action
  end

  scenario "business activity question" do
    when_i_visit_the_checklist_flow
    and_i_also_answer_a_business_question
    then_i_should_see_the_results_page
    and_i_should_see_a_passport_action
    and_i_should_see_an_eori_action
  end

  def when_i_visit_the_checklist_flow
    visit checklist_questions_path
  end

  def and_i_answer_the_basic_questions
    expect(page).to have_content "Do you own a business?"
    choose "No"
    click_on "Next"

    expect(page).to have_content "Are you an EU national living in the UK?"
    choose "No"
    click_on "Next"
  end

  def and_i_also_answer_a_business_question
    expect(page).to have_content "Do you own a business?"
    choose "Yes"
    click_on "Next"

    expect(page).to have_content "Does your business do any of the following activities?"
    check "Sell goods or provide services in the UK"
    click_on "Next"

    expect(page).to have_content "Are you an EU national living in the UK?"
    choose "No"
    click_on "Next"
  end

  def then_i_should_see_the_results_page
    expect(page).to have_content I18n.t!("checklists_results.title")
  end

  def and_i_should_see_a_passport_action
    action = Checklists::Action.find_by_title("Get a new passport")
    expect(page).to have_link(action.title, href: action.title_url)
    expect(page).to have_content action.lead_time
    expect(page).to have_content action.consequence
    expect(page).to have_link(action.guidance_link_text, href: action.guidance_url)
  end

  def and_i_should_not_see_an_eori_action
    action = Checklists::Action.find_by_title("Get an EORI number")
    expect(page).to_not have_link(action.title, href: action.title_url)
  end

  def and_i_should_see_an_eori_action
    action = Checklists::Action.find_by_title("Get an EORI number")
    expect(page).to have_link(action.title, href: action.title_url)
    expect(page).to have_content action.lead_time
    expect(page).to have_content action.consequence
  end
end
