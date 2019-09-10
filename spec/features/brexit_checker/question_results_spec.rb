require "spec_helper"

RSpec.feature "Brexit Checker workflow", type: :feature do
  scenario "business questions" do
    when_i_visit_the_brexit_checker_flow
    and_i_answer_citizen_questions
    and_i_answer_business_questions
    then_i_should_see_the_results_page
    and_i_should_see_a_pet_action
    and_i_should_see_a_tourism_action
  end

  scenario "citizen questions" do
    when_i_visit_the_brexit_checker_flow
    and_i_answer_citizen_questions
    and_i_do_not_answer_business_questions
    then_i_should_see_the_results_page
    and_i_should_see_a_pet_action
    and_i_should_not_see_a_tourism_action
  end

  scenario "skip all questions" do
    when_i_visit_the_brexit_checker_flow
    and_i_dont_answer_enough_questions
    then_i_should_see_the_no_results_page
  end

  def when_i_visit_the_brexit_checker_flow
    visit brexit_checker_questions_path
  end

  def and_i_do_not_answer_business_questions
    answer_question("do-you-own-a-business", "No")
  end

  def and_i_dont_answer_enough_questions
    answer_question("nationality")
    answer_question("living", "Somewhere else")
    answer_question("employment")
    answer_question("travelling")
    answer_question("do-you-own-a-business")
  end

  def and_i_answer_business_questions
    answer_question("do-you-own-a-business", "Yes")
    answer_question("employ-eu-citizens", "No")
    answer_question("personal-data", "No")
    answer_question("eu-uk-government-funding", "No")
    answer_question("public-sector-procurement", "No")
    answer_question("intellectual-property", "No")
    answer_question("business-activity")
    answer_question("sector-business-area", "Tourism")
  end

  def and_i_answer_citizen_questions
    answer_question("nationality", "British")
    answer_question("living", "UK")
    answer_question("employment")
    answer_question("travelling", "To another EU country, Iceland, Liechtenstein, Norway or Switzerland")
    answer_question("activities", "Take your pet")
  end

  def then_i_should_see_the_results_page
    expect(page).to have_content I18n.t!("brexit_checker.results.title")
  end

  def then_i_should_see_the_no_results_page
    expect(page).to have_content I18n.t!("brexit_checker.results.title_no_actions")
  end

  def and_i_should_see_a_pet_action
    action_is_shown("S009")
  end

  def and_i_should_not_see_a_tourism_action
    action_not_shown("T063")
  end

  def and_i_should_see_a_tourism_action
    action_is_shown("T063")
  end

  def action_not_shown(key)
    action = BrexitChecker::Action.find_by_id(key)
    expect(page).to_not have_link(action.title, href: action.title_url)
  end

  def action_is_shown(key)
    action = BrexitChecker::Action.find_by_id(key)
    expect(page).to have_content action.title
    expect(page).to have_content action.lead_time
    expect(page).to have_content action.consequence

    if action.guidance_link_text
      expect(page).to have_link(action.guidance_link_text, href: action.guidance_url)
    end
  end

  def answer_question(key, *options)
    question = BrexitChecker::Question.find_by_key(key)
    expect(page).to have_content(question.text)
    options.each { |o| find_field(o).click }
    click_on "Next"
  end
end
