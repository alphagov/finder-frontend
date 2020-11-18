require "spec_helper"

describe BrexitCheckerController, type: :controller do
  include GovukAbTesting::RspecHelpers
  render_views

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

  context "Testing a new caption for the first question of the checker" do
    %w[A Z].each do |variant|
      it "Variant #{variant} shows the control caption" do
        with_variant TransitionChecker1: variant do
          get :show
          assert_select ".govuk-caption-xl", text: "About you and your family"
          assert_select ".govuk-caption-xl", text: "First answer some questions about you, then about any business you run", count: 0
        end
      end
    end

    it "Variant B shows the alternate caption" do
      with_variant TransitionChecker1: "B" do
        get :show
        assert_select ".govuk-caption-xl", text: "First answer some questions about you, then about any business you run"
        assert_select ".govuk-caption-xl", text: "About you and your family", count: 0
      end
    end
  end
end
