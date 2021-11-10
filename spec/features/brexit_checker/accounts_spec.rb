require "spec_helper"
require "gds_api/test_helpers/account_api"
require "gds_api/test_helpers/email_alert_api"

RSpec.feature "Brexit Checker accounts", type: :feature do
  include GdsApi::TestHelpers::AccountApi
  include GdsApi::TestHelpers::EmailAlertApi
  include GovukPersonalisation::TestHelpers::Features
  include ActionView::Helpers::SanitizeHelper

  let(:mock_results) { %w[nationality-eu] }

  shared_examples "the user is not logged in" do
    context "/transition-check/saved-results" do
      it "redirects to login page" do
        stub_account_api_get_sign_in_url(
          redirect_path: "/transition-check/saved-results",
          mfa: true,
          auth_uri: "/sign-in?this-is-a-stubbed-url",
        )
        given_i_am_on_the_saved_results_page
        expect(page).to have_current_path("http://www.example.com/sign-in?this-is-a-stubbed-url")
      end
    end

    context "/transition-check/edit-saved-results" do
      it "redirects to login page" do
        stub_account_api_get_sign_in_url(
          redirect_path: "/transition-check/edit-saved-results",
          mfa: true,
          auth_uri: "/sign-in?this-is-a-stubbed-url",
        )
        given_i_am_on_the_edit_saved_results_page
        expect(page).to have_current_path("http://www.example.com/sign-in?this-is-a-stubbed-url")
      end
    end

    context "/transition-check/save-your-results/confirm" do
      it "redirects to login page" do
        stub_account_api_get_sign_in_url(
          redirect_path: "/transition-check/save-your-results/confirm?c%5B%5D=nationality-eu",
          mfa: true,
          auth_uri: "/sign-in?this-is-a-stubbed-url",
        )
        given_i_am_on_the_save_results_confirm_page
        expect(page).to have_current_path("http://www.example.com/sign-in?this-is-a-stubbed-url")
      end
    end
  end

  context "the user is not logged in" do
    it_behaves_like "the user is not logged in"
  end

  context "the user is logged in" do
    let(:govuk_account_session) { "placeholder" }
    before { mock_logged_in_session(govuk_account_session) }

    let(:transition_checker_state) { { criteria_keys: criteria_keys, timestamp: 42 } }
    let(:criteria_keys) { %w[nationality-uk] }

    context "the user's session is invalid" do
      before do
        stub_account_api_unauthorized_has_attributes(attributes: %w[transition_checker_state])
      end

      it "logs the user out" do
        given_i_am_on_the_results_page
        expect(page.response_headers["GOVUK-Account-End-Session"]).to eq("1")
      end

      it_behaves_like "the user is not logged in"
    end

    context "the user is authenticated at too low a level" do
      before do
        stub_account_api_forbidden_has_attributes(attributes: %w[transition_checker_state])
      end

      it "doesn't log the user out" do
        given_i_am_on_the_results_page
        expect(page.response_headers["GOVUK-Account-End-Session"]).to be_nil
      end

      it_behaves_like "the user is not logged in"
    end

    context "/transition-check/results" do
      before do
        stub_account_api_has_attributes(
          attributes: %w[transition_checker_state],
          values: {
            "transition_checker_state" => transition_checker_state,
          },
        )
      end

      it "doesn't show the normal call-to-action" do
        given_i_am_on_the_results_page
        expect(page).to_not have_content(I18n.t("brexit_checker.results.email_sign_up_title"))
      end

      it "reads the new account header" do
        given_i_am_on_the_results_page
        expect(page.response_headers["GOVUK-Account-Session"]).to eq(govuk_account_session)
      end

      context "the account header is the empty string" do
        let(:govuk_account_session) { "" }

        it "doesn't consider the user logged in" do
          given_i_am_on_the_results_page
          expect(page.response_headers["GOVUK-Account-Session"]).to be_nil
        end
      end

      context "the querystring differs to the value in the account" do
        it "shows a link to save the new results" do
          given_i_am_on_the_results_page_with(%w[bring-pet-abroad nationality-eu])
          expect(page).to have_content(I18n.t("brexit_checker.results.accounts.results_differ.message"))
        end
      end

      context "the querystring matches what's stored in the account" do
        it "doesn't show a link to save the new results" do
          given_i_am_on_the_results_page_with(criteria_keys)
          expect(page).to_not have_content(I18n.t("brexit_checker.results.accounts.results_differ.message"))
        end

        context "the account has been updated in the last 10 seconds" do
          it "shows a 'saved' notification" do
            Timecop.freeze(Time.zone.at(transition_checker_state[:timestamp] - 9)) do
              given_i_am_on_the_results_page_with(criteria_keys)
              expect(page).to have_content(I18n.t("brexit_checker.results.accounts.results_saved.message"))
            end
          end
        end
      end
    end

    context "/transition-check/saved-results" do
      it "redirects to first question if no previous results present" do
        stub = stub_account_api_has_attributes(attributes: %w[transition_checker_state], values: {})

        given_i_am_on_the_saved_results_page

        expect(stub).to have_been_made

        expect(page).to have_current_path(transition_checker_questions_path)
      end

      it "redirects to previous results if present" do
        stub = stub_account_api_has_attributes(
          attributes: %w[transition_checker_state],
          values: { "transition_checker_state" => transition_checker_state },
        )

        given_i_am_on_the_saved_results_page

        expect(stub).to have_been_made.twice

        expect(page).to have_current_path(transition_checker_results_path(c: %w[nationality-uk]))
      end
    end

    context "/transition-check/edit-saved-results" do
      it "redirects to first question if no previous results present" do
        stub = stub_account_api_has_attributes(attributes: %w[transition_checker_state], values: {})

        given_i_am_on_the_edit_saved_results_page

        expect(stub).to have_been_made

        expect(page).to have_current_path(transition_checker_questions_path)
      end

      it "redirects to first question with responses in query string if results present" do
        stub = stub_account_api_has_attributes(attributes: %w[transition_checker_state], values: { "transition_checker_state" => transition_checker_state })

        given_i_am_on_the_edit_saved_results_page

        expect(stub).to have_been_made

        expect(page).to have_current_path(transition_checker_questions_path(c: %w[nationality-uk], page: 0))
      end
    end

    context "/transition-check/save-your-results/confirm" do
      before do
        stub_account_api_has_attributes(attributes: %w[transition_checker_state], values: { "transition_checker_state" => transition_checker_state }.compact)
        stub_find_or_create_subscriber_list(new_criteria_keys)
      end

      let(:new_criteria_keys) { %w[nationality-eu] }

      context "the querystring differs to the value in the account" do
        it "shows a comparison of the result sets" do
          given_i_am_on_the_save_results_confirm_page_with(new_criteria_keys)
          expect(page).to have_content("British")
          expect(page).to have_content("Another EU country, or Switzerland, Norway, Iceland or Liechtenstein")
        end

        context "the user clicks 'confirm'" do
          it "saves the new results and updates the email alert" do
            given_i_am_on_the_save_results_confirm_page_with(new_criteria_keys)
            stub_alert = stub_account_api_put_email_subscription(name: "transition-checker-results", topic_slug: "your-get-ready-for-brexit-results-a1a2a3a4a5")
            stub_attributes = stub_account_api_set_attributes
            click_on I18n.t("brexit_checker.confirm_changes.update.save_button")
            expect(stub_alert).to have_been_made
            expect(stub_attributes).to have_been_made
          end
        end
      end

      context "the querystring matches what's stored in the account" do
        it "redirects back to the results page" do
          given_i_am_on_the_save_results_confirm_page_with(criteria_keys)
          expect(page).to have_current_path(transition_checker_results_path(c: criteria_keys))
        end
      end

      context "the user has no results stored in their account" do
        let(:transition_checker_state) { nil }

        it "shows a confirmation page" do
          given_i_am_on_the_save_results_confirm_page_with(new_criteria_keys)
          expect(page).to have_content("Confirm you want to save your Brexit checker results")
        end

        context "the user clicks 'confirm'" do
          it "saves the new results and updates the email alert" do
            given_i_am_on_the_save_results_confirm_page_with(new_criteria_keys)
            stub_alert = stub_account_api_put_email_subscription(name: "transition-checker-results", topic_slug: "your-get-ready-for-brexit-results-a1a2a3a4a5")
            stub_attributes = stub_account_api_set_attributes
            click_on I18n.t("brexit_checker.confirm_changes.initial.save_button")
            expect(stub_alert).to have_been_made
            expect(stub_attributes).to have_been_made
          end
        end
      end
    end
  end

  def given_i_am_on_a_question_page
    visit transition_checker_questions_path
  end

  def given_i_am_on_the_results_page
    visit transition_checker_results_path(c: mock_results)
  end

  def given_i_am_on_the_results_page_with(criteria_keys)
    visit transition_checker_results_path(c: criteria_keys)
  end

  def given_i_am_on_the_saved_results_page
    visit transition_checker_saved_results_path
  end

  def given_i_am_on_the_save_results_confirm_page
    visit transition_checker_save_results_confirm_path(c: mock_results)
  end

  def given_i_am_on_the_save_results_confirm_page_with(criteria_keys)
    visit transition_checker_save_results_confirm_path(c: criteria_keys)
  end

  def given_i_am_on_the_edit_saved_results_page
    visit transition_checker_edit_saved_results_path
  end

  def stub_find_or_create_subscriber_list(criteria_keys)
    stub_email_alert_api_creates_subscriber_list(
      {
        "title" => "Get ready for 2021",
        "slug" => "your-get-ready-for-brexit-results-a1a2a3a4a5",
        "tags" => { "brexit_checklist_criteria" => { "any" => criteria_keys } },
        "url" => "/transition-check/results?c%5B%5D=nationality-eu",
      },
    )
  end
end
