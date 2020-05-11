require "spec_helper"

describe SignupPresenter do
  include FixturesHelper

  let(:params) do
    ActionController::Parameters.new({})
  end
  describe "single facet" do
    let(:content_item) do
      {
        "details" => {
          "beta" => false,
          "email_filter_facets" => [
            {
              "facet_id" => "alert_type",
              "facet_name" => "Alert type",
              "facet_choices" => [
                {
                  "key" => "devices",
                  "radio_button_name" => "Medical device alerts",
                },
                {
                  "key" => "drugs",
                  "radio_button_name" => "Drug alerts",
                },
              ],
            },
          ],
        },
      }
    end
    describe "#choices" do
      it "returns an array of signup facets" do
        expect(SignupPresenter.new(content_item, params).choices)
          .to eq([
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
    let(:content_item) do
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
            {
              "facet_id" => "custom_facet",
              "facet_name" => "Custom facet",
              "facet_choices" => [
                {
                  "key" => "custom-facet-key-one",
                  "radio_button_name" => "this is the custom facet",
                  "topic_name" => "This is the custom facet",
                  "prechecked" => false,
                },
              ],
            },
          ],
        },
      }
    end
    describe "#choices" do
      it "returns an array of signup facets" do
        expect(SignupPresenter.new(content_item, params).choices)
          .to eq(
            [
              {
                "facet_id" => "people",
                "facet_name" => "people",
              },
              {
                "facet_id" => "organisations",
                "facet_name" => "organisations",
              },
              {
                "facet_id" => "custom_facet",
                "facet_name" => "Custom facet",
                "facet_choices" => [
                  {
                    "key" => "custom-facet-key-one",
                    "prechecked" => false,
                    "radio_button_name" => "this is the custom facet",
                    "topic_name" => "This is the custom facet",
                  },
                ],
              },
            ],
          )
      end
    end
    describe "#choices?" do
      it "returns true" do
        expect(SignupPresenter.new(content_item, params).choices?).to be true
      end
    end
    describe "#can_modify_choices?" do
      it "returns true" do
        expect(SignupPresenter.new(content_item, params).can_modify_choices?).to be true
      end
    end
  end

  describe "no facets in email signup" do
    let(:content_item) do
      {
        "details" => {
          "email_filter_facets" => [],
        },
      }
    end
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
