require "spec_helper"

RSpec.feature "Brexit Checker accounts", type: :feature do
  context "without accounts enabled" do
    let(:mock_results) { %w[nationality-eu] }

    context "/transition-check/results" do
      it "does not show the login state" do
        given_i_am_on_a_question_page
        expect(page).to_not have_content("Logged in.")
        expect(page).to_not have_content("Not logged in.")
      end
    end

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

  context "with accounts enabled" do
    let(:attribute_service_url) { "http://attribute-service" }

    before do
      ENV["GOVUK_ACCOUNT_OAUTH_CLIENT_ID"] = "id"
      ENV["GOVUK_ACCOUNT_OAUTH_CLIENT_SECRET"] = "secret"

      allow(Rails.configuration).to receive(:feature_flag_govuk_accounts).and_return(true)

      allow_any_instance_of(OidcClient).to receive(:userinfo_endpoint)
        .and_return("#{attribute_service_url}/oidc/user_info")
    end

    let(:mock_results) { %w[nationality-eu] }

    context "the user is not logged in" do
      context "/transition-check/results" do
        it "shows the login state" do
          given_i_am_on_the_results_page
          expect(page).to_not have_content("Logged in.")
          expect(page).to have_content("Not logged in.")
        end
      end

      context "/transition-check/saved-results" do
        before do
          discovery_response = double(authorization_endpoint: "foo", token_endpoint: "foo", userinfo_endpoint: "foo", end_session_endpoint: "foo")

          allow_any_instance_of(OidcClient).to receive(:discover)
            .and_return(discovery_response)

          allow_any_instance_of(OidcClient).to receive(:auth_uri)
            .and_return({ uri: "http://account-mamager/login", state: SecureRandom.hex(16) })
        end

        it "redirects to login page" do
          given_i_am_on_the_saved_results_page
          expect(current_path).to eq(transition_checker_new_session_path)
        end
      end

      context "/transition-check/edit-saved-results" do
        before do
          discovery_response = double(authorization_endpoint: "foo", token_endpoint: "foo", userinfo_endpoint: "foo", end_session_endpoint: "foo")

          allow_any_instance_of(OidcClient).to receive(:discover)
            .and_return(discovery_response)

          allow_any_instance_of(OidcClient).to receive(:auth_uri)
            .and_return({ uri: "http://account-mamager/login", state: SecureRandom.hex(16) })
        end

        it "redirects to login page" do
          given_i_am_on_the_edit_saved_results_page
          expect(current_path).to eq(transition_checker_new_session_path)
        end
      end
    end

    context "the user is logged in" do
      before { log_in }
      after { log_out }

      let(:transition_checker_state) { { criteria_keys: %w[nationality-uk], timestamp: 42 } }

      context "/transition-check/questions" do
        it "does not show the login state" do
          given_i_am_on_a_question_page
          expect(page).to_not have_content("Logged in.")
          expect(page).to_not have_content("Not logged in.")
        end
      end

      context "/transition-check/results" do
        it "shows the login state" do
          given_i_am_on_the_results_page
          expect(page).to have_content("Logged in.")
          expect(page).to_not have_content("Not logged in.")
        end
      end

      context "/transition-check/saved-results" do
        it "redirects to first question if no previous results present" do
          stub = stub_attribute_service_request(:get, body: { claim_value: {} })

          given_i_am_on_the_saved_results_page

          expect(stub).to have_been_made

          expect(page).to have_current_path(transition_checker_questions_path)
          expect(page).to_not have_content("Not logged in.")
        end

        it "redirects to previous results if present" do
          stub = stub_attribute_service_request(:get, body: { claim_value: transition_checker_state })

          given_i_am_on_the_saved_results_page

          expect(stub).to have_been_made

          expect(page).to have_current_path(transition_checker_results_path(c: %w[nationality-uk]))
          expect(page).to_not have_content("Not logged in.")
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
          expect(page).to_not have_content("Not logged in.")
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
                expect(stub_get_success).to have_been_made

                expect(page).to have_content("Logged in")
                expect(page).to have_content("Your results")
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
              expect(stub_success).to have_been_made

              expect(page).to have_current_path(transition_checker_results_path(c: %w[nationality-uk]))
              expect(page).to_not have_content("Not logged in.")
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
              expect(page).to_not have_content("Not logged in.")
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

          it "logs the user out" do
            stub_fail = stub_attribute_service_request(:get, status: 401)

            given_i_am_on_the_saved_results_page

            expect(stub_fail).to have_been_made

            expect(current_path).to eq(transition_checker_questions_path)
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

    def given_i_am_on_the_saved_results_page
      visit transition_checker_saved_results_path
    end

    def given_i_am_on_the_edit_saved_results_page
      visit transition_checker_edit_saved_results_path
    end

    def stub_attribute_service_request(method, access_token: "access-token", status: 200, body: "")
      stub_request(method, "#{attribute_service_url}/v1/attributes/transition_checker_state")
        .with(headers: { "Authorization" => "Bearer #{access_token}" })
        .to_return(status: status, body: body.to_json)
    end
  end
end
