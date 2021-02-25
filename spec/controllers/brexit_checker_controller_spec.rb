require "spec_helper"

describe BrexitCheckerController, type: :controller do
  include GovukAbTesting::RspecHelpers
  render_views

  context "accounts header" do
    before do
      allow(Rails.configuration).to receive(:feature_flag_govuk_accounts).and_return(true)
      stub_request(:get, Services.accounts_api).to_return(status: 200)
    end

    it "disables the search field" do
      get :show
      assert_equal "true", response.headers["X-Slimmer-Remove-Search"]
    end

    it "sets the Vary: GOVUK-Account-Session response header" do
      get :show
      assert response.headers["Vary"].include? "GOVUK-Account-Session"
    end

    it "requests the signed-out header" do
      get :show
      assert_equal "signed-out", response.headers["X-Slimmer-Show-Accounts"]
    end

    context "the GOVUK-Account-Session header is set" do
      it "requests the signed-in header" do
        request.headers["GOVUK-Account-Session"] = "foo"
        get :show
        assert_equal "signed-in", response.headers["X-Slimmer-Show-Accounts"]
      end
    end

    context "with the LoggedIn A/B variant" do
      it "requests the signed-in header" do
        with_variant AccountExperiment: "LoggedIn" do
          get :show
          assert_equal "signed-in", response.headers["X-Slimmer-Show-Accounts"]
        end
      end
    end

    context "with the LoggedOut A/B variant" do
      it "requests the signed-out header" do
        with_variant AccountExperiment: "LoggedOut" do
          get :show
          assert_equal "signed-out", response.headers["X-Slimmer-Show-Accounts"]
        end
      end

      context "the GOVUK-Account-Session header is set" do
        it "requests the signed-in header" do
          with_variant AccountExperiment: "LoggedOut" do
            request.headers["GOVUK-Account-Session"] = "foo"
            get :show
            assert_equal "signed-in", response.headers["X-Slimmer-Show-Accounts"]
          end
        end
      end
    end
  end
end
