require "spec_helper"

RSpec.describe "Sessions controller", type: :request do
  let(:authorization_endpoint) { "http://account-manager/oauth/authorization" }
  let(:end_session_endpoint) { "http://account-manager/oauth/end_session" }
  let(:token_endpoint) { "http://account-manager/oauth/token" }
  let(:userinfo_endpoint) { "http://attribute-service/oidc/user_info" }

  before do
    discovery_response = double(
      authorization_endpoint: authorization_endpoint,
      end_session_endpoint: end_session_endpoint,
      token_endpoint: token_endpoint,
      userinfo_endpoint: userinfo_endpoint,
    )

    allow(Rails.configuration).to receive(:feature_flag_govuk_accounts).and_return(true)
    allow_any_instance_of(OidcClient).to receive(:discover).and_return(discovery_response)
    stub_request(:get, Plek.find("account-manager")).to_return(status: 200)
  end

  around do |example|
    ClimateControl.modify(GOVUK_ACCOUNT_OAUTH_CLIENT_ID: "id", GOVUK_ACCOUNT_OAUTH_CLIENT_SECRET: "secret") do
      example.run
    end
  end

  describe "/login/callback" do
    context "the code is incorrect" do
      before { stub_request(:post, token_endpoint).to_return(status: 404) }

      it "returns a 400" do
        get transition_checker_new_session_callback_path(code: "12345", state: "hello-world")

        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
