require "spec_helper"

RSpec.feature "Brexit Checker workflow", type: :feature do
  include BrexitCheckerHelper

  scenario "business and citizen questions" do
    when_i_visit_the_brexit_checker_flow
    and_i_answer_citizen_questions
    and_i_answer_business_questions
    then_i_see_citizen_and_business_results
    and_i_should_see_a_print_link
    and_i_should_see_share_links
  end

  scenario "business questions only" do
    when_i_visit_the_brexit_checker_flow
    and_i_do_not_answer_citizen_questions
    and_i_answer_business_questions
    then_i_see_business_results_only
    and_i_should_see_a_print_link
    and_i_should_see_share_links
  end

  scenario "citizen questions only" do
    when_i_visit_the_brexit_checker_flow
    and_i_answer_citizen_questions
    and_i_do_not_answer_business_questions
    then_i_see_citizens_results_only
    and_i_should_see_a_print_link
    and_i_should_see_share_links
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
    and_i_should_see_eu_settled_status_scheme
    and_i_should_see_eu_settled_status_scheme
  end

  def then_i_see_business_results_only
    then_i_should_see_the_results_page
    and_i_should_see_the_business_action_header
    and_i_should_not_see_the_citizens_action_header
    and_i_should_see_customs_agent_action
    and_i_should_not_see_eu_settled_status_scheme
  end

  def then_i_see_citizens_results_only
    then_i_should_see_the_results_page
    and_i_should_see_the_citizens_action_header
    and_i_should_not_see_the_business_action_header
    and_i_should_see_citizen_actions_are_grouped
    and_i_should_see_eu_settled_status_scheme
    and_i_should_not_see_customs_agent_action
  end

  def and_i_should_see_share_links
    current_url = CGI.escape(page.current_url)
    expect(page).to have_css("a[href='https://www.facebook.com/sharer/sharer.php?u=#{current_url}']")
    expect(page).to have_css("a[href='https://twitter.com/share?url=#{current_url}']")
    expect(page).to have_css("a[href='https://api.whatsapp.com/send?text=#{current_url}']")
    expect(page).to have_css("a[href='mailto:?body=#{current_url}&subject=Brexit%20checker%20results:%20what%20you%20need%20to%20do']")
    expect(page).to have_css("a[href='http://www.linkedin.com/shareArticle?url=#{current_url}']")
  end

  def and_i_should_see_a_print_link
    expect(page).to have_css(".brexit-checker__print-link", text: "Print your results")
  end

  def and_i_should_not_see_a_print_link
    expect(page).to_not have_css(".brexit-checker__print-link", text: "Print your results")
  end

  def and_i_should_not_see_share_links
    expect(page).to_not have_css(".gem-c-share-links")
  end

  def and_i_should_see_the_citizens_action_header
    expect(page).to have_content I18n.t!("brexit_checker.results.audiences.citizen.heading")
  end

  def and_i_should_see_the_business_action_header
    expect(page).to have_content I18n.t!("brexit_checker.results.audiences.business.heading")
  end

  def and_i_should_not_see_the_citizens_action_header
    expect(page).to_not have_content I18n.t!("brexit_checker.results.audiences.citizen.heading")
  end

  def and_i_should_not_see_the_business_action_header
    expect(page).to_not have_content I18n.t!("brexit_checker.results.audiences.business.heading")
  end

  def when_i_visit_the_brexit_checker_flow
    visit transition_checker_questions_path
  end

  def and_i_should_see_citizen_actions_are_grouped
    group_titles_ordered = ["Visiting the EU", "Visiting the UK", "Visiting Ireland"]

    find_all(".brexit-checker-audience-citizen .brexit-checker-actions__group h3").each_with_index do |group_title, i|
      expect(group_title.text).to eq(group_titles_ordered[i])
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
    answer_question("business-uk-or-eu", "UK")
    answer_question("employ-eu-citizens", "No")
    answer_question("personal-data", "No")
    answer_question("eu-uk-government-funding", "No")
    answer_question("public-sector-procurement", "No")
    answer_question("intellectual-property", "No")
    answer_question("eu-domain", "No")
    answer_question("business-activity", "Send or take goods to EU countries (exporting)")
    answer_question("sector-business-area", "Fisheries (including wholesale)")
  end

  def and_i_answer_citizen_questions
    answer_question("nationality", "Another EU country, or Switzerland, Norway, Iceland or Liechtenstein")
    answer_question("living", "UK")
    answer_question("employment", "Work in the UK")
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

  def and_i_should_see_eu_settled_status_scheme
    action = BrexitChecker::Action.find_by_id("S001")

    # S001 is priority 8 so should not have the urgent tag applied
    expect(page).to_not have_css(".brexit-checker__action-urgent", text: "Apply to the EU Settlement Scheme")

    expect(page).to have_css("h4", text: "Apply to the EU Settlement Scheme by 30 June 2021 to continue living in the UK - you must have arrived in the UK before January 2021")
    expect(page).to have_css(".govuk-link[href='#{action.guidance_url}'][data-track-action]")
    data_track_action = page.find(".govuk-link[href='#{action.guidance_url}']")["data-track-action"]
    expect(data_track_action).to eq("You and your family - Living in the UK - 2.1 - Guidance")
    action_is_shown(action)
    action_has_analytics(action)
  end

  def and_i_should_not_see_eu_settled_status_scheme
    action_not_shown("S001")
  end

  def and_i_should_see_customs_agent_action
    action = BrexitChecker::Action.find_by_id("T099")

    # T099 is priority 9 so should have the urgent tag applied
    expect(page).to have_css(".brexit-checker__action-urgent", text: "Decide how you want to make customs declarations")

    expect(page).to have_css("h3", text: "Decide how you want to make customs declarations and whether you need to get someone to deal with customs for you")
    expect(page).to have_css(".govuk-link[href='#{action.guidance_url}'][data-track-action]")
    data_track_action = page.find(".govuk-link[href='#{action.guidance_url}']")["data-track-action"]
    expect(data_track_action).to eq("Your business or organisation - 1.2 - Guidance")
    action_is_shown(action)
    action_has_analytics(action)
  end

  def and_i_should_not_see_customs_agent_action
    action_not_shown("T099")
  end

  def action_not_shown(key)
    action = BrexitChecker::Action.find_by_id(key)
    expect(page).to_not have_link(action.title, href: action.title_url)
  end

  def action_is_shown(action)
    expect(page).to have_content action.title
    expect(page).to have_content action.lead_time if action.lead_time
    expect(page).to have_content action.consequence

    if action.guidance_link_text
      expect(page).to have_link(action.guidance_link_text, href: action.guidance_url)
    end
  end

  def action_has_analytics(action)
    expect(page).to have_css(".govuk-link[href='#{action.guidance_url}'][data-track-category='brexit-checker-results']")
    expect(page).to have_css(".govuk-link[href='#{action.guidance_url}'][data-track-label='#{action.guidance_url}']")
    expect(page).to have_css(".govuk-link[href='#{action.guidance_url}'][data-ecommerce-path='#{action.guidance_path}']")
    expect(page).to have_css(".govuk-link[href='#{action.guidance_url}'][data-ecommerce-row]")
  end
end
