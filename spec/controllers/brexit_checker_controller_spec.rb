require "spec_helper"

describe BrexitCheckerController, type: :controller do
  include GovukAbTesting::RspecHelpers
  render_views

  context "results page AB test setup" do
    subject { get :results }

    %w[A B Z].each do |variant|
      it "Variant #{variant} includes the AB testing headers and metatags" do
        with_variant TransitionUrgency5: variant do
          expect(subject).to render_template(:results)
        end
      end
    end
  end

  context "results page AB test urgency styling" do
    let(:params_to_get_some_urgent_results) do
      {
        c: %w[
          owns-operates-business-organisation
          visiting-driving
          visiting-ie
          visiting-eu
          visiting-row
          travel-eu-business-no
          working-uk
          living-uk
          nationality-uk
        ],
      }
    end

    %w[A Z].each do |variant|
      it "Variant #{variant} does not show the alternate urgency styling" do
        with_variant TransitionUrgency5: variant do
          get :results, params: params_to_get_some_urgent_results
          expect(response.body).to_not have_css(".brexit-checker__action-urgent")
          expect(response.body).to_not have_text("Urgent")
        end
      end
    end

    it "Variant B shows the alternate urgency styling" do
      with_variant TransitionUrgency5: "B" do
        get :results, params: params_to_get_some_urgent_results
        expect(response.body).to have_css(".brexit-checker__action-urgent")
        expect(response.body).to have_css(".brexit-checker__action-urgent-tag", text: "Urgent")
      end
    end
  end

  context "accounts header AB test setup" do
    before do
      allow(Rails.configuration).to receive(:feature_flag_govuk_accounts).and_return(true)
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
