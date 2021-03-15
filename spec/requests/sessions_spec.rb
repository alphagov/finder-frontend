require "spec_helper"
require "gds_api/test_helpers/account_api"

RSpec.describe "Sessions controller", type: :request do
  include GdsApi::TestHelpers::AccountApi

  before do
    allow(Rails.configuration).to receive(:feature_flag_govuk_accounts).and_return(true)
    stub_request(:get, Plek.find("account-manager")).to_return(status: 200)
  end

  describe "/login/callback" do
    context "the code is incorrect" do
      before { stub_account_api_rejects_auth_response }

      it "returns a 400" do
        get transition_checker_new_session_callback_path(code: "12345", state: "hello-world")

        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
