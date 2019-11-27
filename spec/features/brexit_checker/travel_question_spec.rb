require "spec_helper"

RSpec.feature "Filtering options based on criteria", type: :feature do
  include BrexitCheckerHelper

  scenario "User's living question choice is not displayed as a travel question option" do
    when_i_visit_the_brexit_checker_flow
    and_i_choose_uk_for_the_living_question
    then_i_should_not_see_uk_as_an_option_for_the_travel_question
  end

  def when_i_visit_the_brexit_checker_flow
    visit brexit_checker_questions_path
  end

  def and_i_choose_uk_for_the_living_question
    click_on "Continue"
    answer_question("living", "UK")
    click_on "Continue"
    click_on "Continue"
  end

  def then_i_should_not_see_uk_as_an_option_for_the_travel_question
    question = BrexitChecker::Question.find_by_key("travelling")
    expect(page).to have_content(question.text)
    expect(page).not_to have_content("To the UK")
  end
end
