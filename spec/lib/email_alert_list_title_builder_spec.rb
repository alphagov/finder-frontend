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
    signup_json.fetch("details").fetch("email_filter_facets")
  end

  context "one choice for one facet selected" do
    let(:filter) do
      {
        "sector_business_area" => %w(94b3cfe2-af89-4744-b8d7-7fc79edcbc85),
      }
    end

    it "will join one choices from one facets in a list" do
      is_expected.to eq("EU Exit guidance in the following category: 'Agriculture and forestry (including wholesale)'")
    end
  end

  context "one choice for multiple facets selected" do
    let(:filter) do
      {
        "sector_business_area" => %w(94b3cfe2-af89-4744-b8d7-7fc79edcbc85),
        "business_activity" => %w(d422aa2e-59ad-4986-8ef0-973959878912),
      }
    end

    it "will join one choice from multiple facets in a list, separated with commas" do
      is_expected.to eq("EU Exit guidance in the following categories: 'Agriculture and forestry (including wholesale)', 'Import from the EU'")
    end
  end


  context "a selected facet with one overridden facet_choice is overwritten" do
    let(:filter) do
      {
        "sector_business_area" => %w(94b3cfe2-af89-4744-b8d7-7fc79edcbc85),
        "public_sector_procurement" => %w(33fc20d7-6a45-40c9-b31f-e4678f962ff1),
      }
    end

    it "will include the overwritten facet_choice" do
      is_expected.to eq("EU Exit guidance in the following categories: 'Agriculture and forestry (including wholesale)', 'Public sector procurement - defence contracts'")
    end
  end

  context "multiple selected facets with multiple facet_choice overrides are overwritten" do
    let(:filter) do
      {
        "sector_business_area" => %w(94b3cfe2-af89-4744-b8d7-7fc79edcbc85),
        "public_sector_procurement" => %w(33fc20d7-6a45-40c9-b31f-e4678f962ff1 f165dc7c-7cef-446a-bdfd-8a1ca685d091),
      }
    end

    it "will include the overwritten facet_choices" do
      is_expected.to eq("EU Exit guidance in the following categories: 'Agriculture and forestry (including wholesale)', 'Public sector procurement - defence contracts', 'Public sector procurement - civil government contracts'")
    end
  end


  context "multiple choices for multiple facets selected" do
    let(:filter) do
      {
        "sector_business_area" => %w(94b3cfe2-af89-4744-b8d7-7fc79edcbc85 01b51981-1ad6-4e45-9b14-b8a57fcb4204),
        "business_activity" => %w(d422aa2e-59ad-4986-8ef0-973959878912 7283b8e1-840f-49da-967f-c0a512a3f531),
      }
    end

    it "will join multiple choices from multiple facets in a list, separated with commas" do
      is_expected.to eq("EU Exit guidance in the following categories: 'Agriculture and forestry (including wholesale)', 'Electronics, parts and machinery', 'Import from the EU', 'Export to the EU'")
    end
  end
end
