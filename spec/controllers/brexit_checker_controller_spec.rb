require "spec_helper"

describe BrexitCheckerController, type: :controller do
  include GovukAbTesting::RspecHelpers
  render_views

  context "accounts header AB test setup" do
    before do
      allow(Rails.configuration).to receive(:feature_flag_govuk_accounts).and_return(true)
      stub_request(:get, Services.accounts_api).to_return(status: 200)
    end

    %w[LoggedIn LoggedOut].each do |variant|
      it "Variant #{variant} disables the search field" do
        with_variant AccountExperiment: variant do
          get :results
          expect(response.headers["X-Slimmer-Remove-Search"]).to eq("true")
        end
      end
    end

    it "Variant LoggedIn requests the signed-in header" do
      with_variant AccountExperiment: "LoggedIn" do
        get :results
        expect(response.headers["X-Slimmer-Show-Accounts"]).to eq("signed-in")
      end
    end

    it "Variant LoggedOut requests the signed-out header" do
      with_variant AccountExperiment: "LoggedOut" do
        get :results
        expect(response.headers["X-Slimmer-Show-Accounts"]).to eq("signed-out")
      end
    end
  end
end
