require "spec_helper"

RSpec.feature "Navigating Brexit Checker questions", type: :feature do
  include BrexitCheckerHelper

  scenario "navigate to previous question" do
    when_i_visit_the_brexit_checker_flow
    and_i_answer_travel_questions
    and_i_click_on_the_back_link
    then_i_should_see_the_activities_question
    and_my_previous_activities_choice_is_selected
  end

  def when_i_visit_the_brexit_checker_flow
    visit brexit_checker_questions_path
    expect(page).to have_link("Back", href: "/get-ready-brexit-check")
  end

  def and_i_answer_travel_questions
    3.times { click_on "Continue" }
    answer_question("travelling", "To another EU country, or Switzerland, Norway, Iceland or Liechtenstein")
    answer_question("activities", "Take your pet")
  end

  def and_i_click_on_the_back_link
    click_on "Back"
  end

  def then_i_should_see_the_activities_question
    question = BrexitChecker::Question.find_by_key("activities")
    expect(page).to have_content(question.text)
  end

  def and_my_previous_activities_choice_is_selected
    expect(page).to have_checked_field("Take your pet")
  end
end
