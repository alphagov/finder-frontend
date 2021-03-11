require "spec_helper"

RSpec.describe "When account is enabled", type: :request do
  before do
    allow(Rails.configuration).to receive(:feature_flag_govuk_accounts).and_return(true)
  end

  context "and accounts is returning a 503 error code" do
    before { stub_request(:get, Plek.find("account-manager")).to_return(status: 503) }

    describe "/login" do
      it "redirects a user to the accounts 503 error page" do
        get transition_checker_new_session_path

        expect(response).to redirect_to(Plek.find("account-manager"))
      end
    end

    describe "/login/callback" do
      it "redirects a user to the accounts 503 error page" do
        get transition_checker_new_session_callback_path

        expect(response).to redirect_to(Plek.find("account-manager"))
      end
    end

    describe "/logout" do
      it "redirects a user to the accounts 503 error page" do
        get transition_checker_end_session_path

        expect(response.body).to eq("Redirecting to #{Plek.find('account-manager')}/sign-out?continue=1")
      end

      context "With a continue parameter" do
        it "redirects a user to the accounts 503 error page" do
          get transition_checker_end_session_path, params: { continue: 1 }

          expect(response.body).to eq("Redirecting to #{Plek.find('account-manager')}/sign-out?done=1")
        end
      end

      context "With a done parameter" do
        it "redirects a user to /transition" do
          get transition_checker_end_session_path, params: { done: 1 }

          expect(response.body).to eq("Redirecting to /transition")
        end
      end
    end

    describe "/save-your-results" do
      it "redirects a user to the accounts 503 error page" do
        get transition_checker_save_results_path

        expect(response).to redirect_to(Plek.find("account-manager"))
      end
    end

    describe "/save-your-results/confirm" do
      it "redirects a user to the accounts 503 error page" do
        get transition_checker_save_results_confirm_path

        expect(response).to redirect_to(Plek.find("account-manager"))
      end
    end

    describe "/save-your-results/email-signup" do
      it "redirects a user to the accounts 503 error page" do
        get transition_checker_save_results_email_signup_path

        expect(response).to redirect_to(Plek.find("account-manager"))
      end
    end

    describe "/saved-results" do
      it "redirects a user to the accounts 503 error page" do
        get transition_checker_saved_results_path

        expect(response).to redirect_to(Plek.find("account-manager"))
      end
    end

    describe "/edit-saved-results" do
      it "redirects a user to the accounts 503 error page" do
        get transition_checker_edit_saved_results_path

        expect(response).to redirect_to(Plek.find("account-manager"))
      end
    end
  end
end
