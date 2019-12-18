require "spec_helper"

RSpec.feature "Brexit Checker workflow", type: :feature do
  include BrexitCheckerHelper

  scenario "business and citizen questions" do
    when_i_visit_the_brexit_checker_flow
    and_i_answer_citizen_questions
    and_i_answer_business_questions
    then_i_see_citizen_and_business_results
  end

  scenario "business questions only" do
    when_i_visit_the_brexit_checker_flow
    and_i_do_not_answer_citizen_questions
    and_i_answer_business_questions
    then_i_see_business_results_only
  end

  scenario "citizen questions only" do
    when_i_visit_the_brexit_checker_flow
    and_i_answer_citizen_questions
    and_i_do_not_answer_business_questions
    then_i_see_citizens_results_only
  end

  scenario "skip all questions" do
    when_i_visit_the_brexit_checker_flow
    and_i_dont_answer_enough_questions
    then_i_should_see_the_no_results_page
  end

  def then_i_see_citizen_and_business_results
    then_i_should_see_the_results_page
    and_i_should_see_citizen_actions_are_grouped
    and_i_should_see_the_citizens_action_header
    and_i_should_see_the_business_action_header
    and_i_should_see_a_pet_action
    and_i_should_see_a_tourism_action
    and_citizen_results_audience_analyitics_tracking_should_be_present
    and_business_results_audience_analyitics_tracking_should_be_present
  end

  def then_i_see_business_results_only
    then_i_should_see_the_results_page
    expect(page).to_not have_content I18n.t!("brexit_checker.results.audiences.citizen.heading")
    and_i_should_see_the_business_action_header
    and_i_should_see_a_ce_mark_action
    and_business_results_audience_analyitics_tracking_should_be_present
  end

  def then_i_see_citizens_results_only
    then_i_should_see_the_results_page
    and_i_should_see_the_citizens_action_header
    expect(page).to_not have_content I18n.t!("brexit_checker.results.audiences.business.heading")
    and_i_should_see_citizen_actions_are_grouped
    and_i_should_see_a_pet_action
    and_i_should_not_see_a_tourism_action
    and_citizen_results_audience_analyitics_tracking_should_be_present
  end

  def and_i_should_see_the_citizens_action_header
    expect(page).to have_content I18n.t!("brexit_checker.results.audiences.citizen.heading")
  end

  def and_i_should_see_the_business_action_header
    expect(page).to have_content I18n.t!("brexit_checker.results.audiences.business.heading")
  end

  def when_i_visit_the_brexit_checker_flow
    visit brexit_checker_questions_path
  end

  def and_i_should_see_citizen_actions_are_grouped
    group_titles_ordered = ["Visiting the EU", "Visiting the UK", "Visiting Ireland"]

    find_all(".brexit-checker-audience-citizen section.brexit-checker-actions__group h3").each_with_index do |group_title, i|
      expect(group_title.text).to eq(group_titles_ordered[i])
    end
  end

  def and_business_results_audience_analyitics_tracking_should_be_present
    and_business_actions_section_has_ecommerce_tracking
    and_business_actions_section_has_data_search_query_attributes
  end

  def and_business_actions_section_has_ecommerce_tracking
    section = find('.brexit-checker-business-actions', visible: false)
    expect(section['data-analytics-ecommerce']).to eq("")
    expect(section['data-ecommerce-start-index']).to eq("1")
    expect(section['data-list-title']).to eq("Brexit checker results: Your business or organisation")
  end

  def and_business_actions_section_has_data_search_query_attributes
    section = find('.brexit-checker-business-actions', visible: false)
    expect(section['data-search-query']).to eq("")
  end

  def and_citizen_results_audience_analyitics_tracking_should_be_present
    and_citizens_groups_section_has_ecommerce_tracking
    and_citizens_groups_section_has_data_search_query_attributes
  end

  def and_citizens_groups_section_has_ecommerce_tracking
    group_titles_ordered = ["Visiting the EU", "Visiting the UK", "Visiting Ireland"]

    find_all('.brexit-checker-citizen-audience section.brexit-checker-actions__group', visible: false).each_with_index do |group, i|
      expect(group['data-analytics-ecommerce']).to eq("")
      expect(group['data-ecommerce-start-index']).to eq("#{i + 1}")
      expect(group['data-list-title']).to eq("Brexit checker results: You and your family - #{group_titles_ordered[i]}")
    end
  end

  def and_citizens_groups_section_has_data_search_query_attributes
    find_all('.brexit-checker-citizen-audience section.brexit-checker-actions__group', visible: false).each do |group|
      expect(group['data-search-query']).to eq("")
    end
  end

  def and_i_do_not_answer_citizen_questions
    answer_question("nationality")
    answer_question("living")
    answer_question("employment")
    answer_question("travelling")
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
    answer_question("travelling-business", "Yes")
    answer_question("travelling", "To another EU country, or Switzerland, Norway, Iceland or Liechtenstein")
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

  def and_i_should_see_a_ce_mark_action
    action_is_shown("T001")
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
end
