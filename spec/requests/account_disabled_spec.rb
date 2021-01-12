require "spec_helper"

RSpec.describe "When account is disabled", type: :request do
  before do
    allow(Rails.configuration).to receive(:feature_flag_govuk_accounts).and_return(false)
  end

  describe "/login" do
    it "shows the user the 404 page" do
      get transition_checker_new_session_path

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "/login/callback" do
    it "shows the user the 404 page" do
      get transition_checker_new_session_callback_path

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "/logout" do
    it "shows the user the 404 page" do
      get transition_checker_end_session_path

      expect(response.body).to eq("Redirecting to #{Services.accounts_api}/sign-out?continue=1")
    end

    context "With a continue parameter" do
      it "shows the user the 404 page" do
        get transition_checker_end_session_path, params: { continue: 1 }

        expect(response.body).to eq("Redirecting to #{Services.accounts_api}/sign-out?done=1")
      end
    end

    context "With a done parameter" do
      it "Redirects user to /transition" do
        get transition_checker_end_session_path, params: { done: 1 }

        expect(response.body).to eq("Redirecting to /transition")
      end
    end
  end

  describe "/save-your-results" do
    it "shows the user the 404 page" do
      get transition_checker_save_results_path

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "/save-your-results/confirm" do
    it "shows the user the 404 page" do
      get transition_checker_save_results_confirm_path

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "/save-your-results/email-signup" do
    it "shows the user the 404 page" do
      get transition_checker_save_results_email_signup_path

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "/saved-results" do
    it "shows the user the 404 page" do
      get transition_checker_saved_results_path

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "/edit-saved-results" do
    it "shows the user the 404 page" do
      get transition_checker_edit_saved_results_path

      expect(response).to have_http_status(:not_found)
    end
  end
end
