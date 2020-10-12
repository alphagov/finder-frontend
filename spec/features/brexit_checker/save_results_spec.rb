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

  before do
    ENV["GOVUK_ACCOUNT_OAUTH_CLIENT_ID"] = "Application's OAuth client ID"
    ENV["GOVUK_ACCOUNT_OAUTH_CLIENT_SECRET"] = "secret!"
    ENV["GOVUK_ACCOUNT_OAUTH_CLIENT_KEY_UUID"] = "fake_key_uuid"
    ENV["GOVUK_ACCOUNT_OAUTH_CLIENT_KEY"] = AccountSignupHelper.test_ec_key_fixture
    allow(Rails.configuration).to receive(:feature_flag_govuk_accounts).and_return(true)
    discovery_response = double(authorization_endpoint: "foo", token_endpoint: "foo", userinfo_endpoint: "foo", end_session_endpoint: "foo")
    allow_any_instance_of(OidcClient).to receive(:userinfo_endpoint).and_return("http://attribute-service/oidc/user_info")
    allow_any_instance_of(OidcClient).to receive(:discover).and_return(discovery_response)
    allow_any_instance_of(OidcClient).to receive(:auth_uri).and_return({ uri: "http://account-mamager/login", state: SecureRandom.hex(16) })
    stub_email_subscription_confirmation
  end

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
    expect(form["action"]).to eql(Plek.find("account-manager"))
  end

  def stub_email_subscription_confirmation
    fixture = { "subscriber_list": { "slug": "test-slug" } }.to_json
    expected_url = "http://email-alert-api.dev.gov.uk/subscriber-lists?tags%5Bbrexit_checklist_criteria%5D%5Bany%5D%5B0%5D=nationality-eu"

    stub_request(:get, expected_url).to_return(status: 200, body: fixture)
  end
end
