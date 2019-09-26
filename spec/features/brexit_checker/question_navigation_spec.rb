require "spec_helper"

RSpec.feature "Navigating Brexit Checker questions", type: :feature do
  scenario "navigate to previous page" do
    when_i_visit_the_brexit_checker_flow
    and_i_answer_the_nationality_question
    then_i_should_see_the_living_question

    when_i_click_on_the_back_link
    then_i_should_see_the_nationality_question
  end

  def when_i_visit_the_brexit_checker_flow
    visit brexit_checker_questions_path
    expect(page).to have_link("Back", href: "/get-ready-brexit-check")
  end

  def and_i_answer_the_nationality_question
    answer_question("nationality", "British")
  end

  def then_i_should_see_the_living_question
    question = BrexitChecker::Question.find_by_key("living")
    expect(page).to have_content(question.text)
  end

  def when_i_click_on_the_back_link
    click_on "Back"
  end

  def then_i_should_see_the_nationality_question
    question = BrexitChecker::Question.find_by_key("nationality")
    expect(page).to have_content(question.text)
  end

  def answer_question(key, *options)
    question = BrexitChecker::Question.find_by_key(key)
    expect(page).to have_content(question.text)
    options.each { |o| find_field(o).click }
    click_on "Next"
  end
end
