require "spec_helper"
require 'gds_api/test_helpers/email_alert_api'

RSpec.feature "Checklist email signup", type: :feature do
  include GdsApi::TestHelpers::ContentStore
  include GdsApi::TestHelpers::EmailAlertApi

  let(:subscriber_list) do
    {
      "title" => "the Get ready for Brexit tool",
      "slug" => "brexit-checklist-does-not-own-business-eu-national",
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
    visit "/get-ready-brexit-check/results?do_you_own_a_business%5B%5D=does-not-own-business&eu_national_in_uk%5B%5D=eu-national"
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
    expect(page).to have_current_path("/email/subscriptions/new?topic_id=brexit-checklist-does-not-own-business-eu-national")
  end
end
