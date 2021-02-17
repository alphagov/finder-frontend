require "spec_helper"
require "gds_api/test_helpers/email_alert_api"

RSpec.feature "Brexit Checker create GOV.UK Account", type: :feature do
  include GdsApi::TestHelpers::ContentStore
  include GdsApi::TestHelpers::EmailAlertApi

  before do
    ENV["GOVUK_ACCOUNT_OAUTH_CLIENT_ID"] = "Application's OAuth client ID"
    ENV["GOVUK_ACCOUNT_OAUTH_CLIENT_SECRET"] = "secret!"
    allow(Rails.configuration).to receive(:feature_flag_govuk_accounts).and_return(true)
    discovery_response = double(authorization_endpoint: "foo", token_endpoint: "foo", userinfo_endpoint: "foo", end_session_endpoint: "foo")
    allow_any_instance_of(OidcClient).to receive(:userinfo_endpoint).and_return("http://attribute-service/oidc/user_info")
    allow_any_instance_of(OidcClient).to receive(:discover).and_return(discovery_response)
    allow_any_instance_of(OidcClient).to receive(:auth_uri).and_return({ uri: "http://account-mamager/login", state: SecureRandom.hex(16) })
    allow_any_instance_of(OidcClient).to receive(:tokens!).and_return({ access_token: "access-token", refresh_token: "refresh-token" })
    allow_any_instance_of(OidcClient).to receive(:submit_jwt).and_return({ access_token: "access-token", refresh_token: "refresh-token", result: "jwt-id" })
    stub_email_subscription_confirmation
    stub_request(:get, Services.accounts_api).to_return(status: 200)
  end

  context "accounts is enabled" do
    scenario "user clicks Create a GOV.UK account" do
      given_im_on_the_results_page
      then_i_click_to_subscribe
      and_i_am_taken_to_choose_how_to_subscribe_page
      and_i_click_the_create_account_button
      i_get_redirected_to_sign_up
    end
  end

  context "accounts is enabled but is returning 503" do
    before do
      stub_request(:get, Services.accounts_api).to_return(status: 503)
    end

    scenario "user is only given the chance to subscribe via email" do
      given_im_on_the_results_page
      then_i_click_to_subscribe
      i_see_the_subscribe_by_email_page
    end
  end

  context "accounts is enabled but is returning 500" do
    before do
      stub_request(:get, Services.accounts_api).to_return(status: 500)
    end

    scenario "user is still given a chance to subscribe with an account" do
      given_im_on_the_results_page
      then_i_click_to_subscribe
      and_i_am_taken_to_choose_how_to_subscribe_page
      and_i_click_the_create_account_button
      i_get_redirected_to_sign_up
    end
  end

  def given_im_on_the_results_page
    visit transition_checker_results_url(c: %w[nationality-eu])
  end

  def i_see_the_subscribe_by_email_page
    expect(page).to have_current_path(transition_checker_email_signup_url(c: %w[nationality-eu]))
    expect(page).to have_content(I18n.t("brexit_checker.email_signup.sign_up_heading"))
  end

  def then_i_click_to_subscribe
    click_on "Subscribe"
  end

  def and_i_am_taken_to_choose_how_to_subscribe_page
    expect(page).to have_current_path(transition_checker_save_results_url(c: %w[nationality-eu]))
  end

  def and_i_click_the_create_account_button
    form = page.find("form#account-signup")
    expect(form.text).to eql("Create a GOV.UK account")
    expect(form["method"]).to eql("post")
    click_on I18n.t("brexit_checker.account_signup.create_account.cta_button")
  end

  def i_get_redirected_to_sign_up
    expect(page.current_url).to include("&state=jwt-id")
  end

  def stub_email_subscription_confirmation
    stub_email_alert_api_creates_subscriber_list(
      {
        "title" => "Get ready for 2021",
        "slug" => "test-slug",
        "tags" => { "brexit_checklist_criteria" => { "any" => %w[nationality-eu] } },
        "url" => "/transition-check/results?c%5B%5D=nationality-eu",
      },
    )
  end
end
