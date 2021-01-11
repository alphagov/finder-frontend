require "spec_helper"
require "gds_api/test_helpers/email_alert_api"

RSpec.feature "Brexit Checker accounts", type: :feature do
  include GdsApi::TestHelpers::EmailAlertApi

  before do
    stub_request(:get, Services.accounts_api).to_return(status: 200)
  end

  context "without accounts enabled" do
    let(:mock_results) { %w[nationality-eu] }

    context "/transition-check/saved-results" do
      it "returns a 404" do
        given_i_am_on_the_saved_results_page
        expect(page.status_code).to eq(404)
      end
    end

    context "/transition-check/edit-saved-results" do
      it "returns a 404" do
        given_i_am_on_the_edit_saved_results_page
        expect(page.status_code).to eq(404)
      end
    end

    def given_i_am_on_a_question_page
      visit transition_checker_questions_path
    end

    def given_i_am_on_the_results_page
      visit transition_checker_results_path(c: mock_results)
    end

    def given_i_am_on_the_saved_results_page
      visit transition_checker_saved_results_path
    end

    def given_i_am_on_the_edit_saved_results_page
      visit transition_checker_edit_saved_results_path
    end
  end

  context "accounts is enabled but not returning JWT" do
    let(:criteria_keys) { %i[nationality-eu] }

    before do
      allow(Rails.configuration).to receive(:feature_flag_govuk_accounts).and_return(true)
      allow_any_instance_of(BrexitCheckerHelper).to receive(:account_signup_jwt).and_raise

      stub_email_alert_api_has_subscriber_list(
        {
          "title" => "Get ready for 2021",
          "slug" => "your-get-ready-for-brexit-results-a1a2a3a4a5",
          "tags" => { "brexit_checklist_criteria" => { "any" => criteria_keys } },
          "url" => "/transition-check/results?c%5B%5D=nationality-eu",
        },
      )
    end

    context "/transition-check/save-results" do
      it "redirects to the email signup page" do
        visit transition_checker_save_results_path(c: criteria_keys)
        expect(page).to have_content(I18n.t("brexit_checker.email_signup.sign_up_heading"))
      end
    end
  end

  context "with accounts enabled" do
    let(:attribute_service_url) { "http://attribute-service" }

    before do
      ENV["GOVUK_ACCOUNT_OAUTH_CLIENT_ID"] = "id"
      ENV["GOVUK_ACCOUNT_OAUTH_CLIENT_SECRET"] = "secret"

      allow(Rails.configuration).to receive(:feature_flag_govuk_accounts).and_return(true)

      allow_any_instance_of(OidcClient).to receive(:userinfo_endpoint)
        .and_return("#{attribute_service_url}/oidc/user_info")

      discovery_response = double(authorization_endpoint: "foo", token_endpoint: "foo", userinfo_endpoint: "foo", end_session_endpoint: "foo")

      allow_any_instance_of(OidcClient).to receive(:discover)
        .and_return(discovery_response)

      allow_any_instance_of(OidcClient).to receive(:auth_uri)
        .and_return({ uri: "http://account-mamager/login", state: SecureRandom.hex(16) })
    end

    let(:mock_results) { %w[nationality-eu] }

    context "the user is not logged in" do
      context "/transition-check/results" do
        it "shows the normal call-to-action" do
          given_i_am_on_the_results_page
          expect(page).to have_content(I18n.t("brexit_checker.results.email_sign_up_title"))
        end
      end

      context "/transition-check/saved-results" do
        it "redirects to login page" do
          given_i_am_on_the_saved_results_page
          expect(current_path).to eq(transition_checker_new_session_path)
        end
      end

      context "/transition-check/edit-saved-results" do
        it "redirects to login page" do
          given_i_am_on_the_edit_saved_results_page
          expect(current_path).to eq(transition_checker_new_session_path)
        end
      end

      context "/transition-check/save-your-results/confirm" do
        it "redirects to login page" do
          given_i_am_on_the_save_results_confirm_page
          expect(current_path).to eq(transition_checker_new_session_path)
        end
      end
    end

    context "the user is logged in" do
      before { log_in }
      after { log_out }

      let(:transition_checker_state) { { criteria_keys: criteria_keys, timestamp: 42 } }
      let(:criteria_keys) { %w[nationality-uk] }

      context "/transition-check/results" do
        before { stub_attribute_service_request(:get, body: { claim_value: transition_checker_state }) }

        it "doesn't show the normal call-to-action" do
          given_i_am_on_the_results_page
          expect(page).to_not have_content(I18n.t("brexit_checker.results.email_sign_up_title"))
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
          stub = stub_attribute_service_request(:get, body: { claim_value: {} })

          given_i_am_on_the_saved_results_page

          expect(stub).to have_been_made

          expect(page).to have_current_path(transition_checker_questions_path)
        end

        it "redirects to previous results if present" do
          stub = stub_attribute_service_request(:get, body: { claim_value: transition_checker_state })

          given_i_am_on_the_saved_results_page

          expect(stub).to have_been_made.twice

          expect(page).to have_current_path(transition_checker_results_path(c: %w[nationality-uk]))
        end
      end

      context "/transition-check/edit-saved-results" do
        it "redirects to first question if no previous results present" do
          stub = stub_attribute_service_request(:get, body: { claim_value: {} })

          given_i_am_on_the_edit_saved_results_page

          expect(stub).to have_been_made

          expect(page).to have_current_path(transition_checker_questions_path)
        end

        it "redirects to first question with responses in query string if results present" do
          stub = stub_attribute_service_request(:get, body: { claim_value: transition_checker_state })

          given_i_am_on_the_edit_saved_results_page

          expect(stub).to have_been_made

          expect(page).to have_current_path(transition_checker_questions_path(c: %w[nationality-uk], page: 0))
        end
      end

      context "/transition-check/save-your-results/confirm" do
        before { stub_attribute_service_request(:get, body: { claim_value: transition_checker_state }) }

        let(:new_criteria_keys) { %w[nationality-eu] }

        context "the querystring differs to the value in the account" do
          before do
            stub_email_check(status: email_status)
            stub_subscriber_list_exists(new_criteria_keys)
          end

          let(:email_status) { 200 }

          it "shows a comparison of the result sets" do
            given_i_am_on_the_save_results_confirm_page_with(new_criteria_keys)
            expect(page).to have_content("British")
            expect(page).to have_content("Another EU country, or Switzerland, Norway, Iceland or Liechtenstein")
          end

          context "the user does not have an email subscription" do
            let(:email_status) { 404 }

            it "prompt the user to sign up to email alerts" do
              given_i_am_on_the_save_results_confirm_page_with(new_criteria_keys)
              click_on I18n.t("brexit_checker.confirm_changes.save_button")
              expect(page).to have_content(I18n.t("brexit_checker.confirm_changes_email_signup.heading"))
            end

            context "the user wants email alerts" do
              it "creates an email alert" do
                stub = stub_update_emails
                stub_attribute_service_request(:put)
                given_i_am_on_the_save_results_confirm_page_with(new_criteria_keys)
                click_on I18n.t("brexit_checker.confirm_changes.save_button")
                find_field(I18n.t("brexit_checker.confirm_changes_email_signup.radio.yes")).click
                click_on I18n.t("brexit_checker.confirm_changes_email_signup.save_button")
                expect(stub).to have_been_made
              end
            end
          end

          context "the user has an email subscription" do
            it "updates the existing email alert automatically" do
              stub = stub_update_emails
              stub_attribute_service_request(:put)
              given_i_am_on_the_save_results_confirm_page_with(new_criteria_keys)
              click_on I18n.t("brexit_checker.confirm_changes.save_button")
              expect(page).to_not have_content(I18n.t("brexit_checker.confirm_changes_email_signup.heading"))
              expect(stub).to have_been_made
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

      context "the access token has expired" do
        context "the refresh token is valid" do
          before { allow_token_refresh }

          context "/transition-check/results" do
            context "token expires before the GET" do
              it "refreshes the access token and retries" do
                stub_get_fail = stub_attribute_service_request(:get, status: 401)
                stub_get_success = stub_attribute_service_request(
                  :get,
                  access_token: "new-access-token",
                  body: { claim_value: transition_checker_state },
                )

                given_i_am_on_the_saved_results_page

                expect(stub_get_fail).to have_been_made
                expect(stub_get_success).to have_been_made.twice
              end
            end
          end

          context "/transition-check/saved-results" do
            it "refreshes the access token and retries" do
              stub_fail = stub_attribute_service_request(:get, status: 401)
              stub_success = stub_attribute_service_request(
                :get,
                access_token: "new-access-token",
                body: { claim_value: transition_checker_state },
              )

              given_i_am_on_the_saved_results_page

              expect(stub_fail).to have_been_made
              expect(stub_success).to have_been_made.twice

              expect(page).to have_current_path(transition_checker_results_path(c: %w[nationality-uk]))
            end
          end

          context "/transition-check/edit-saved-results" do
            it "refreshes the access token and retries" do
              stub_fail = stub_attribute_service_request(:get, status: 401)
              stub_success = stub_attribute_service_request(
                :get,
                access_token: "new-access-token",
                body: { claim_value: transition_checker_state },
              )

              given_i_am_on_the_edit_saved_results_page

              expect(stub_fail).to have_been_made
              expect(stub_success).to have_been_made

              expect(page).to have_current_path(transition_checker_questions_path(c: %w[nationality-uk], page: 0))
            end
          end

          def allow_token_refresh
            new_access_token = Rack::OAuth2::AccessToken::Bearer.new(
              access_token: "new-access-token",
              refresh_token: "new-refresh-token",
            )

            client_dub = double("Client")
            allow(client_dub).to receive(:"refresh_token=").with("refresh-token")
            allow(client_dub).to receive(:access_token!).and_return(new_access_token)

            allow_any_instance_of(OidcClient).to receive(:client).and_return(client_dub)
          end
        end

        context "the refresh token is invalid" do
          before { forbid_token_refresh }

          it "logs the user out and triggers a new login flow" do
            stub_fail = stub_attribute_service_request(:get, status: 401)

            given_i_am_on_the_saved_results_page

            expect(stub_fail).to have_been_made

            expect(current_path).to eq(transition_checker_new_session_path)
          end

          def forbid_token_refresh
            client_dub = double("Client")
            allow(client_dub).to receive(:"refresh_token=").with("refresh-token")
            allow(client_dub).to receive(:access_token!)
              .and_raise(Rack::OAuth2::Client::Error.new(401, { error: "bad", error_description: "bad" }))

            allow_any_instance_of(OidcClient).to receive(:client).and_return(client_dub)
          end
        end
      end

      def log_in
        access_token = Rack::OAuth2::AccessToken::Bearer.new(
          access_token: "access-token",
          refresh_token: "refresh-token",
        )

        sub = "subject-identifier"

        allow_any_instance_of(OidcClient).to receive(:callback)
          .and_return({ access_token: access_token, sub: sub })

        stub_request(:get, "http://account-manager.dev.gov.uk/api/v1/ephemeral-state")
          .with(headers: { "Authorization" => "Bearer access-token" })
          .to_return(status: 200, body: "{}")

        visit transition_checker_new_session_callback_path(state: "state", code: "code")
      end

      def log_out
        visit transition_checker_end_session_path
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

    def stub_attribute_service_request(method, access_token: "access-token", status: 200, body: "")
      stub_request(method, "#{attribute_service_url}/v1/attributes/transition_checker_state")
        .with(headers: { "Authorization" => "Bearer #{access_token}" })
        .to_return(status: status, body: body.to_json)
    end

    def stub_email_check(status: 204)
      stub_request(:get, "http://account-manager.dev.gov.uk/api/v1/transition-checker/email-subscription")
        .to_return(status: status)
    end

    def stub_update_emails
      stub_request(:post, "http://account-manager.dev.gov.uk/api/v1/transition-checker/email-subscription")
        .to_return(status: 200)
    end

    def stub_subscriber_list_exists(criteria_keys)
      stub_email_alert_api_has_subscriber_list(
        {
          "title" => "Get ready for 2021",
          "slug" => "your-get-ready-for-brexit-results-a1a2a3a4a5",
          "tags" => { "brexit_checklist_criteria" => { "any" => criteria_keys } },
          "url" => "/transition-check/results?c%5B%5D=nationality-eu",
        },
      )
    end
  end
end
