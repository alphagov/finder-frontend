require "spec_helper"

describe SignupPresenter do
  include FixturesHelper

  let(:params) {
    ActionController::Parameters.new({})
  }
  describe "single facet" do
    let(:content_item) {
      {
        "details" =>
          { "beta" => false,
           "email_signup_choice" =>
             [{ "key" => "devices",
               "radio_button_name" => "Medical device alerts" },
              { "key" => "drugs",
                "radio_button_name" => "Drug alerts" }],
           "email_filter_by" => "alert_type",
           "email_filter_name" => "Alert Type" },
      }
    }
    describe "#choices" do
      it "returns an array of signup facets" do
        expect(SignupPresenter.new(content_item, params).choices).
          to eq([
                  { "facet_choices" => [{ "key" => "devices",
                                         "radio_button_name" => "Medical device alerts" },
                                        { "key" => "drugs",
                                          "radio_button_name" => "Drug alerts" }],
                   "facet_id" => "alert_type",
                   "facet_name" => "Alert type" },
                ])
      end
    end
    describe "#choices?" do
      it "returns true" do
        expect(SignupPresenter.new(content_item, params).choices?).to be true
      end
    end
    describe "#can_modify_choices?" do
      it "returns false" do
        expect(SignupPresenter.new(content_item, params).can_modify_choices?).to be true
      end
    end
  end

  describe "multiple facets" do
    let(:content_item) {
      {
        "details" => {
          "email_filter_facets" => [
            {
              "facet_id" => "people",
              "facet_name" => "people",
            },
            {
              "facet_id" => "organisations",
              "facet_name" => "organisations",
            },
          ],
        },
      }
    }
    describe "#choices" do
      it "returns an array of signup facets" do
        expect(SignupPresenter.new(content_item, params).choices).
          to eq([
                  {
                    "facet_id" => "people",
                    "facet_name" => "people",
                  },
                  {
                    "facet_id" => "organisations",
                    "facet_name" => "organisations",
                  },
])
      end
    end
    describe "#choices?" do
      it "returns true" do
        expect(SignupPresenter.new(content_item, params).choices?).to be true
      end
    end
    describe "#can_modify_choices?" do
      it "returns false" do
        expect(SignupPresenter.new(content_item, params).can_modify_choices?).to be false
      end
    end
  end

  describe "no facets in email signup" do
    let(:content_item) {
      {
        "details" => {
          "email_signup_choice" => [],
        },
      }
    }
    describe "#choices" do
      it "returns an empty array" do
        expect(SignupPresenter.new(content_item, params).choices).to eq([])
      end
    end
    describe "#choices?" do
      it "returns false" do
        expect(SignupPresenter.new(content_item, params).choices?).to be false
      end
    end
    describe "#can_modify_choices?" do
      it "returns an empty array" do
        expect(SignupPresenter.new(content_item, params).can_modify_choices?).to be false
      end
    end
  end
end
