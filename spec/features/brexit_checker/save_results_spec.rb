require "spec_helper"
require "gds_api/test_helpers/email_alert_api"

RSpec.feature "Brexit Checker create GOV.UK Account", type: :feature do
  include GdsApi::TestHelpers::ContentStore
  include GdsApi::TestHelpers::EmailAlertApi

  let(:subscriber_list) do
    {
      "title" => "Get ready for 2021",
      "slug" => "your-get-ready-for-brexit-results-a1a2a3a4a5",
      "description" => "[You can view a copy of your results on GOV.UK.](https://www.test.gov.uk/transition-check/results?c%5B%5D=nationality-eu)",
      "tags" => { "brexit_checklist_criteria" => { "any" => %w[nationality-eu] } },
      "url" => "/transition-check/results?c%5B%5D=nationality-eu",
      "group_id" => BrexitCheckerController::SUBSCRIBER_LIST_GROUP_ID,
    }
  end

  let(:jwt) { "i_am_a_string_pretending_to_be_a_jwt" }

  scenario "user clicks Create a GOV.UK account" do
    given_im_on_the_results_page
    then_i_click_to_subscribe
    and_i_am_taken_to_choose_how_to_subscribe_page
    i_see_a_create_account_button
  end

  def given_im_on_the_results_page
    visit transition_checker_results_url(c: %w[nationality-eu])
  end

  def then_i_click_to_subscribe
    click_on "Subscribe"
  end

  def and_i_am_taken_to_choose_how_to_subscribe_page
    expect(page).to have_current_path(transition_checker_save_results_url(c: %w[nationality-eu]))
  end

  def i_see_a_create_account_button
    form = page.find("form#account-signup")
    expect(form.text).to eql("Create a GOV.UK account")
    expect(form["method"]).to eql("post")
    expect(form["action"]).to eql("http://account.service.dev.test.gov.uk/")
  end
end
