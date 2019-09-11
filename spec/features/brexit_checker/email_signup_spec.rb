require "spec_helper"
require 'gds_api/test_helpers/email_alert_api'

RSpec.feature "Brexit Checker email signup", type: :feature do
  include GdsApi::TestHelpers::ContentStore
  include GdsApi::TestHelpers::EmailAlertApi

  let(:subscriber_list) do
    {
      "title" => "Your Get ready for Brexit results",
      "slug" => "your-get-ready-for-brexit-results-a1a2a3a4a5",
      "description" => "[You can view a copy of your results on GOV.UK.](http://www.test.gov.uk/results?c[]=does-not-own-business&c[]=eu-national)",
      "tags" => { "brexit_checklist_criteria" => { "any" => %w[does-not-own-business eu-national] } },
      "url" => "/results?c[]=does-not-own-business&c[]=eu-national"
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
    and_i_am_taken_to_email_alert_frontend
  end

  def given_im_on_the_results_page
    visit "/get-ready-brexit-check/results?c%5B%5D=does-not-own-business&c%5B%5D=eu-national"
  end

  def and_email_alert_api_has_subscriber_list
    stub_email_alert_api_has_subscriber_list(subscriber_list)
  end

  def and_email_alert_api_does_not_have_subscriber_list
    stub_email_alert_api_does_not_have_subscriber_list(subscriber_list)
  end

  def and_email_alert_api_creates_subscriber_list
    stub_email_alert_api_creates_subscriber_list(subscriber_list)
  end

  def then_i_click_to_signup_to_emails
    click_on "Subscribe" # on main results page
    click_on "Subscribe" # on overview of subscription page
  end

  def and_i_am_taken_to_email_alert_frontend
    expect(page).to have_current_path("/email/subscriptions/new?topic_id=your-get-ready-for-brexit-results-a1a2a3a4a5")
  end
end
