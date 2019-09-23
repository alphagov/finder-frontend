require "spec_helper"
require "gds_api/test_helpers/email_alert_api"

RSpec.feature "Brexit Checker email signup", type: :feature do
  include GdsApi::TestHelpers::ContentStore
  include GdsApi::TestHelpers::EmailAlertApi

  let(:subscriber_list) do
    {
      "title" => "Your Get ready for Brexit results",
      "slug" => "your-get-ready-for-brexit-results-a1a2a3a4a5",
      "description" => "[You can view a copy of your results on GOV.UK.](https://www.test.gov.uk/get-ready-brexit-check/results?c%5B%5D=nationality-eu)",
      "tags" => { "brexit_checklist_criteria" => { "any" => %w[nationality-eu] } },
      "url" => "/get-ready-brexit-check/results?c%5B%5D=nationality-eu",
      "group_id" => BrexitCheckerController::SUBSCRIBER_LIST_GROUP_ID,
    }
  end

  scenario "user clicks to signup to email alerts with existing subscriber list" do
    given_im_on_the_results_page
    and_email_alert_api_has_subscriber_list
    then_i_click_to_signup_to_emails
    and_i_am_taken_to_email_alert_frontend
  end

  scenario "user clicks to signup to email alerts without existing subscriber list" do
    given_im_on_the_results_page
    and_email_alert_api_does_not_have_subscriber_list
    and_email_alert_api_creates_subscriber_list
    then_i_click_to_signup_to_emails
    and_the_subscriber_list_was_created
    and_i_am_taken_to_email_alert_frontend
  end

  def given_im_on_the_results_page
    visit brexit_checker_results_path(c: %w(nationality-eu))
  end

  def and_email_alert_api_has_subscriber_list
    stub_email_alert_api_has_subscriber_list(subscriber_list)
  end

  def and_email_alert_api_does_not_have_subscriber_list
    stub_email_alert_api_does_not_have_subscriber_list(subscriber_list)
  end

  def and_email_alert_api_creates_subscriber_list
    @create_request = stub_email_alert_api_creates_subscriber_list(subscriber_list)
                        .with(body: subscriber_list.except("slug").as_json)
  end

  def then_i_click_to_signup_to_emails
    click_on "Subscribe" # on main results page
    click_on "Subscribe" # on overview of subscription page
  end

  def and_the_subscriber_list_was_created
    expect(@create_request).to have_been_requested
  end

  def and_i_am_taken_to_email_alert_frontend
    expect(page).to have_current_path(email_alert_frontend_signup_path(topic_id: "your-get-ready-for-brexit-results-a1a2a3a4a5"))
  end
end
