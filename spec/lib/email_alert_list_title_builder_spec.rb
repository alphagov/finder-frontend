require "spec_helper"
require "email_alert_list_title_builder"

describe EmailAlertListTitleBuilder do
  subject do
    described_class.call(
      filter: filter,
      subscription_list_title_prefix: subscription_list_title_prefix,
      facets: facets,
    )
  end

  let(:subscription_list_title_prefix) { "EU Exit guidance" }
  let(:facets) do
    signup_json = JSON.parse(File.read(Rails.root.join("features", "fixtures", "business_readiness_email_signup.json")))
    signup_json.fetch('details').fetch('email_filter_facets')
  end

  context "one choice for one facet selected" do
    let(:filter) do
      {
        "sector_business_area" => %w(agriculture),
      }
    end

    it "will join one choices from one facets in a list" do
      is_expected.to eq("EU Exit guidance in the following category: 'Agriculture and forestry (including wholesale)'")
    end
  end

  context "one choice for multiple facets selected" do
    let(:filter) do
      {
        "sector_business_area" => %w(agriculture),
        "business_activity" => %w(buying)
      }
    end

    it "will join one choice from multiple facets in a list, separated with commas" do
      is_expected.to eq("EU Exit guidance in the following categories: 'Agriculture and forestry (including wholesale)', 'Buy products or goods from abroad'")
    end
  end


  context "a selected facet with one overridden facet_choice is overwritten" do
    let(:filter) do
      {
        "sector_business_area" => %w(agriculture),
        "public_sector_procurement" => %w(defence-contracts)
      }
    end

    it "will include the overwritten facet_choice" do
      is_expected.to eq("EU Exit guidance in the following categories: 'Agriculture and forestry (including wholesale)', 'Public sector procurement - defence contracts'")
    end
  end

  context "multiple selected facets with multiple facet_choice overrides are overwritten" do
    let(:filter) do
      {
        "sector_business_area" => %w(agriculture),
        "public_sector_procurement" => %w(defence-contracts civil-government-contracts)
      }
    end

    it "will include the overwritten facet_choices" do
      is_expected.to eq("EU Exit guidance in the following categories: 'Agriculture and forestry (including wholesale)', 'Public sector procurement - defence contracts', 'Public sector procurement - civil government contracts'")
    end
  end


  context "multiple choices for multiple facets selected" do
    let(:filter) do
      {
        "sector_business_area" => %w(agriculture electronics-parts-machinery),
        "business_activity" => %w(buying selling)
      }
    end

    it "will join multiple choices from multiple facets in a list, separated with commas" do
      is_expected.to eq("EU Exit guidance in the following categories: 'Agriculture and forestry (including wholesale)', 'Electronics, parts and machinery', 'Buy products or goods from abroad', 'Sell products or goods abroad'")
    end
  end
end
