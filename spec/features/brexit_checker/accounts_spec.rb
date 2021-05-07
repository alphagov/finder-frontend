require "spec_helper"
require "gds_api/test_helpers/account_api"
require "gds_api/test_helpers/email_alert_api"

RSpec.feature "Brexit Checker accounts", type: :feature do
  include GdsApi::TestHelpers::AccountApi
  include GdsApi::TestHelpers::EmailAlertApi

  let(:mock_results) { %w[nationality-eu] }

  shared_examples "the user is not logged in" do
    context "/transition-check/results" do
      it "shows the normal call-to-action" do
        given_i_am_on_the_results_page
        expect(page).to have_content(I18n.t("brexit_checker.results.email_sign_up_title"))
      end
    end

    context "/transition-check/saved-results" do
      it "redirects to login page" do
        given_i_am_on_the_saved_results_page
        querystring = { level_of_authentication: "level1", redirect_path: "/transition-check/saved-results" }.to_query
        expect(page).to have_current_path("#{Plek.find('frontend')}/sign-in?#{querystring}")
      end
    end

    context "/transition-check/edit-saved-results" do
      it "redirects to login page" do
        given_i_am_on_the_edit_saved_results_page
        querystring = { level_of_authentication: "level1", redirect_path: "/transition-check/edit-saved-results" }.to_query
        expect(page).to have_current_path("#{Plek.find('frontend')}/sign-in?#{querystring}")
      end
    end

    context "/transition-check/save-your-results/confirm" do
      it "redirects to login page" do
        given_i_am_on_the_save_results_confirm_page
        querystring = { level_of_authentication: "level1", redirect_path: "/transition-check/save-your-results/confirm?c%5B%5D=nationality-eu" }.to_query
        expect(page).to have_current_path("#{Plek.find('frontend')}/sign-in?#{querystring}")
      end
    end
  end

  context "the user is not logged in" do
    it_behaves_like "the user is not logged in"
  end

  context "the user is logged in" do
    let(:govuk_account_session) { "placeholder" }
    before { page.driver.header("GOVUK-Account-Session", govuk_account_session) }
    after  { page.driver.header("GOVUK-Account-Session", nil) }

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
      before { stub_account_api_has_attributes(attributes: %w[transition_checker_state], values: { "transition_checker_state" => transition_checker_state }) }

      it "doesn't show the normal call-to-action" do
        given_i_am_on_the_results_page
        expect(page).to_not have_content(I18n.t("brexit_checker.results.email_sign_up_title"))
      end

      it "reads the new account header" do
        given_i_am_on_the_results_page
        expect(page.response_headers["GOVUK-Account-Session"]).to eq("placeholder")
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
        stub = stub_account_api_has_attributes(attributes: %w[transition_checker_state], values: { "transition_checker_state" => transition_checker_state })

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
      before { stub_account_api_has_attributes(attributes: %w[transition_checker_state], values: { "transition_checker_state" => transition_checker_state }) }

      let(:new_criteria_keys) { %w[nationality-eu] }

      context "the querystring differs to the value in the account" do
        before { stub_find_or_create_subscriber_list(new_criteria_keys) }

        context "the user has an email subscription" do
          before { stub_account_api_has_email_subscription }

          it "shows a comparison of the result sets" do
            given_i_am_on_the_save_results_confirm_page_with(new_criteria_keys)
            expect(page).to have_content("British")
            expect(page).to have_content("Another EU country, or Switzerland, Norway, Iceland or Liechtenstein")
          end

          it "updates the existing email alert automatically" do
            stub = stub_account_api_set_email_subscription(slug: "your-get-ready-for-brexit-results-a1a2a3a4a5")
            stub_account_api_set_attributes
            given_i_am_on_the_save_results_confirm_page_with(new_criteria_keys)
            click_on I18n.t("brexit_checker.confirm_changes.save_button")
            expect(page).to_not have_content(I18n.t("brexit_checker.confirm_changes_email_signup.heading"))
            expect(stub).to have_been_made
          end
        end

        context "the user does not have an email subscription" do
          before { stub_account_api_does_not_have_email_subscription }

          it "prompt the user to sign up to email alerts" do
            given_i_am_on_the_save_results_confirm_page_with(new_criteria_keys)
            click_on I18n.t("brexit_checker.confirm_changes.save_button")
            expect(page).to have_content(I18n.t("brexit_checker.confirm_changes_email_signup.heading"))
          end

          context "the user wants email alerts" do
            it "creates an email alert" do
              stub = stub_account_api_set_email_subscription(slug: "your-get-ready-for-brexit-results-a1a2a3a4a5")
              stub_account_api_set_attributes
              given_i_am_on_the_save_results_confirm_page_with(new_criteria_keys)
              click_on I18n.t("brexit_checker.confirm_changes.save_button")
              find_field(I18n.t("brexit_checker.confirm_changes_email_signup.radio.yes")).click
              click_on I18n.t("brexit_checker.confirm_changes_email_signup.save_button")
              expect(stub).to have_been_made
            end
          end
        end
      end

      context "the querystring matches what's stored in the account" do
        it "redirects back to the results page" do
          given_i_am_on_the_save_results_confirm_page_with(criteria_keys)
          expect(page).to have_current_path(transition_checker_results_path(c: criteria_keys))
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
