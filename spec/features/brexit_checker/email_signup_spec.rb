require "spec_helper"
require "gds_api/test_helpers/email_alert_api"

RSpec.feature "Brexit Checker email signup", type: :feature do
  include GdsApi::TestHelpers::ContentStore
  include GdsApi::TestHelpers::EmailAlertApi

  let(:subscriber_list) do
    {
      "title" => "Get ready for 2021",
      "slug" => "your-get-ready-for-brexit-results-a1a2a3a4a5",
      "description" => "[You can view a copy of your results on GOV.UK.](https://www.test.gov.uk/transition-check/results?c%5B%5D=nationality-eu)",
      "tags" => { "brexit_checklist_criteria" => { "any" => %w[nationality-eu] } },
      "url" => "/transition-check/results?c%5B%5D=nationality-eu",
    }
  end

  context "without the GOV.UK Account feature flag" do
    scenario "user clicks to signup to email alerts with existing subscriber list" do
      given_im_on_the_results_page
      and_email_alert_api_has_subscriber_list
      then_i_click_to_subscribe # on main results page
      then_i_click_to_subscribe # on overview of subscription page
      and_i_am_taken_to_email_alert_frontend
    end

    scenario "user clicks to signup to email alerts without existing subscriber list" do
      given_im_on_the_results_page
      and_email_alert_api_does_not_have_subscriber_list
      and_email_alert_api_creates_subscriber_list
      then_i_click_to_subscribe # on main results page
      then_i_click_to_subscribe # on overview of subscription page
      and_the_subscriber_list_was_created
      and_i_am_taken_to_email_alert_frontend
    end
  end

  context "with the GOV.UK Account feature flag" do
    before do
      ENV["GOVUK_ACCOUNT_OAUTH_CLIENT_ID"] = "Application's OAuth client ID"
      ENV["GOVUK_ACCOUNT_OAUTH_CLIENT_SECRET"] = "secret"
      ENV["GOVUK_ACCOUNT_JWT_KEY_UUID"] = "fake_key_uuid"
      ENV["GOVUK_ACCOUNT_JWT_KEY_PEM"] = AccountSignupHelper.test_ec_key_fixture
      allow(Rails.configuration).to receive(:feature_flag_govuk_accounts).and_return(true)
      discovery_response = double(authorization_endpoint: "foo", token_endpoint: "foo", userinfo_endpoint: "foo", end_session_endpoint: "foo")
      allow_any_instance_of(OidcClient).to receive(:userinfo_endpoint).and_return("http://attribute-service/oidc/user_info")
      allow_any_instance_of(OidcClient).to receive(:discover).and_return(discovery_response)
      allow_any_instance_of(OidcClient).to receive(:auth_uri).and_return({ uri: "http://account-mamager/login", state: SecureRandom.hex(16) })
    end

    scenario "user clicks to signup to email alerts with existing subscriber list" do
      given_im_on_the_results_page
      and_email_alert_api_has_subscriber_list
      then_i_click_to_subscribe
      and_i_am_taken_to_choose_how_to_subscribe_page
      then_i_click_email_alerts_only
      and_i_am_taken_to_email_alert_signup_page
      then_i_click_to_subscribe
      and_i_am_taken_to_email_alert_frontend
    end

    scenario "user clicks to signup to email alerts without existing subscriber list" do
      given_im_on_the_results_page
      and_email_alert_api_does_not_have_subscriber_list
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
