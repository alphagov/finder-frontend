require "spec_helper"

describe BrexitCheckerController, type: :controller do
  include GovukPersonalisation::TestHelpers::Requests

  render_views

  context "accounts header" do
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
      before { mock_logged_in_session }

      it "requests the signed-in header" do
        get :show
        assert_equal "signed-in", response.headers["X-Slimmer-Show-Accounts"]
      end
    end
  end
end
