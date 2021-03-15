require "spec_helper"
require "gds_api/test_helpers/account_api"
require "gds_api/test_helpers/email_alert_api"

RSpec.feature "Brexit Checker email signup", type: :feature do
  include GdsApi::TestHelpers::AccountApi
  include GdsApi::TestHelpers::ContentStore
  include GdsApi::TestHelpers::EmailAlertApi

  let(:subscriber_list) do
    {
      "title" => "Brexit checker results",
      "slug" => "your-get-ready-for-brexit-results-a1a2a3a4a5",
      "tags" => { "brexit_checklist_criteria" => { "any" => %w[nationality-eu] } },
      "url" => "/transition-check/results?c%5B%5D=nationality-eu",
    }
  end

  context "without the GOV.UK Account feature flag" do
    scenario "user clicks to signup to email alerts" do
      given_im_on_the_results_page
      and_email_alert_api_creates_subscriber_list
      then_i_click_to_subscribe # on main results page
      then_i_click_to_subscribe # on overview of subscription page
      and_the_subscriber_list_was_created
      and_i_am_taken_to_email_alert_frontend
    end
  end

  context "with the GOV.UK Account feature flag" do
    before do
      allow(Rails.configuration).to receive(:feature_flag_govuk_accounts).and_return(true)
      stub_request(:get, Plek.find("account-manager")).to_return(status: 200)
    end

    scenario "user clicks to signup to email alerts" do
      given_im_on_the_results_page
      and_email_alert_api_creates_subscriber_list
      then_i_click_to_subscribe
      and_i_am_taken_to_choose_how_to_subscribe_page
      then_i_click_email_alerts_only
      and_i_am_taken_to_email_alert_signup_page
      then_i_click_to_subscribe
      and_the_subscriber_list_was_created
      and_i_am_taken_to_email_alert_frontend
    end
  end

  def given_im_on_the_results_page
    visit transition_checker_results_path(c: %w[nationality-eu])
  end

  def and_email_alert_api_creates_subscriber_list
    @create_request = stub_email_alert_api_creates_subscriber_list(subscriber_list)
                        .with(body: subscriber_list.except("slug").as_json)
  end

  def then_i_click_email_alerts_only
    click_on "Subscribe to get email updates"
  end

  def then_i_click_to_subscribe
    click_on "Subscribe"
  end

  def and_the_subscriber_list_was_created
    expect(@create_request).to have_been_requested
  end

  def and_i_am_taken_to_email_alert_frontend
    expect(page).to have_current_path(email_alert_frontend_signup_path(topic_id: "your-get-ready-for-brexit-results-a1a2a3a4a5"))
  end

  def and_i_am_taken_to_email_alert_signup_page
    expect(page).to have_current_path(transition_checker_email_signup_url(c: %w[nationality-eu]))
  end

  def and_i_am_taken_to_choose_how_to_subscribe_page
    expect(page).to have_current_path(transition_checker_save_results_url(c: %w[nationality-eu]))
  end
end
