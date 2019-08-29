require "spec_helper"

RSpec.feature "Questions workflow", type: :feature do
  scenario "business questions" do
    when_i_visit_the_checklist_flow
    and_i_answer_business_questions
    then_i_should_see_the_results_page
    and_i_should_see_a_passport_action
    and_i_should_see_an_eori_action
  end

  scenario "citizen questions" do
    when_i_visit_the_checklist_flow
    and_i_do_not_answer_business_questions
    and_i_answer_citizen_questions
    then_i_should_see_the_no_results_page # we have no results here
    and_i_should_not_see_a_passport_action
    and_i_should_not_see_an_eori_action
  end

  def when_i_visit_the_checklist_flow
    visit checklist_questions_path
  end

  def and_i_do_not_answer_business_questions
    answer_question("do_you_own_a_business", "No")
  end

  def and_i_answer_business_questions
    answer_question("do_you_own_a_business", "Yes")
    answer_question("sector_business_area", "Tourism")
    answer_question("business_activity")
    answer_question("employ_eu_citizens", "No")
    answer_question("personal_data", "No")
    answer_question("intellectual_property", "No")
    answer_question("eu_uk_government_funding", "No")
    answer_question("public_sector_procurement", "No")
    and_i_answer_citizen_questions
  end

  def and_i_answer_citizen_questions
    answer_question("nationality", "UK")
    answer_question("living", "Rest of world")
    answer_question("travelling-to-eu-2", "Yes", "You plan to bring your pet")
    answer_question("property", "Yes")
    answer_question("returning-2", "Yes")
  end

  def then_i_should_see_the_results_page
    expect(page).to have_content I18n.t!("checklists_results.title")
  end

  def then_i_should_see_the_no_results_page
    expect(page).to have_content I18n.t!("checklists_results.title_no_actions")
  end

  def and_i_should_see_a_passport_action
    action_is_shown("T002")
  end

  def and_i_should_not_see_a_passport_action
    action_not_shown("T002")
  end

  def and_i_should_not_see_an_eori_action
    action_not_shown("T001")
  end

  def and_i_should_see_an_eori_action
    action_is_shown("T001")
  end

  def action_not_shown(key)
    action = Checklists::Action.find_by_id(key)
    expect(page).to_not have_link(action.title, href: action.title_url)
  end

  def action_is_shown(key)
    action = Checklists::Action.find_by_id(key)
    expect(page).to have_link(action.title, href: action.title_url)
    expect(page).to have_content action.lead_time
    expect(page).to have_content action.consequence

    if action.guidance_link_text
      expect(page).to have_link(action.guidance_link_text, href: action.guidance_url)
    end
  end

  def answer_question(key, *options)
    question = Checklists::Question.find_by_key(key)
    expect(page).to have_content(question.text)
    options.each { |o| find_field(o).click }
    click_on "Next"
  end
end
