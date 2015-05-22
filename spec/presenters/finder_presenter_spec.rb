require 'spec_helper'

RSpec.describe FinderPresenter do
  include GovukContentSchemaExamples

  subject(:presenter) { described_class.new(content_item, values) }

  let(:government_presenter) { described_class.new(government_finder_content_item) }

  let(:minimal_policy_presenter) { described_class.new(minimal_policy_content_item) }

  let(:national_applicability_presenter) { described_class.new(national_applicability_content_item) }

  let(:national_applicability_with_internal_policies_presenter) { described_class.new(national_applicability_with_internal_policies_content_item) }

  let(:policies_presenter) { described_class.new(policies_finder_content_item) }

  let(:content_item) {
    dummy_http_response = double("net http response",
      code: 200,
      body: govuk_content_schema_example('finder').to_json,
      headers: {}
    )
    GdsApi::Response.new(dummy_http_response).to_ostruct
  }

  let(:values) { {} }

  let(:government_finder_content_item) {
    dummy_http_response = double("net http response",
      code: 200,
      body: govuk_content_schema_example('policy_programme', 'policy').to_json,
      headers: {}
    )
    GdsApi::Response.new(dummy_http_response).to_ostruct
  }

  let(:minimal_policy_content_item) {
    dummy_http_response = double("net http response",
      code: 200,
      body: govuk_content_schema_example('minimal_policy_area', 'policy').to_json,
      headers: {}
    )
    GdsApi::Response.new(dummy_http_response).to_ostruct
  }

  let(:national_applicability_content_item) {
    dummy_http_response = double("net http response",
      code: 200,
      body: govuk_content_schema_example('policy_with_inapplicable_nations', 'policy').to_json,
      headers: {}
    )
    GdsApi::Response.new(dummy_http_response).to_ostruct
  }

  let(:policies_finder_content_item) {
    dummy_http_response = double("net http response",
      code: 200,
      body: govuk_content_schema_example('policies_finder', 'finder').to_json,
      headers: {}
    )
    GdsApi::Response.new(dummy_http_response).to_ostruct
  }

  let(:internal_policies) {
    {
      details: OpenStruct.new(
        facets: [],
        nation_applicability: OpenStruct.new(
          applies_to: [
            "england",
            "northern_ireland"
          ],
          alternative_policies: [
            OpenStruct.new(
              nation: "scotland",
              alt_policy_url: "http://www.gov.uk/scottish-policy-url"
            ),
            OpenStruct.new(
              nation: "wales",
              alt_policy_url: "http://www.gov.uk/welsh-policy-url"
            )
          ]
        )
      )
    }
  }

  let(:national_applicability_with_internal_policies_content_item) {
    dummy_http_response = double("net http response",
      code: 200,
      body: govuk_content_schema_example('policy_with_inapplicable_nations', 'policy').to_json,
      headers: {}
    )
    ostruct_hash = GdsApi::Response.new(dummy_http_response).to_ostruct.marshal_dump
    OpenStruct.new(
      ostruct_hash.merge(internal_policies)
    )
  }

  describe "facets" do
    it "returns the correct facets" do
      subject.facets.to_a.select{ |f| f.type == "date" }.length.should == 1
      subject.facets.to_a.select{ |f| f.type == "text" }.length.should == 3
    end

    it "returns the correct filters" do
      subject.filters.length.should == 2
    end

    it "returns the correct metadata" do
      subject.metadata.length.should == 3
    end

    it "returns correct keys for each facet type" do
      subject.date_metadata_keys.should =~ %w{date_of_introduction}
      subject.text_metadata_keys.should =~ %w{place_of_origin walk_type}
    end
  end

  describe "#label_for_metadata_key" do
    it "finds the correct key" do
      subject.label_for_metadata_key("date_of_introduction").should == "Introduced"
    end
  end

  describe "#atom_url" do
    context "with no values" do
      it "returns the finder URL appended with .atom" do
        presenter.atom_url.should == "/mosw-reports.atom"
      end
    end

    context "with some values" do
      let(:values) do
        {
          keyword: "legal",
          format: "publication",
          state: "open",
        }
      end

      it "returns the finder URL appended with .atom and query params" do
        presenter.atom_url.should == "/mosw-reports.atom?format=publication&keyword=legal&state=open"
      end
    end

    context "when the finder is ordered by title" do
      it "atom_url is disabled" do
        policies_presenter.atom_feed_enabled?.should == false
      end
    end
  end

  describe "a government finder" do
    it "sets the government flag" do
      government_presenter.government?.should == true
    end

    it "exposes the government_content_section" do
      government_presenter.government_content_section.should == "policies"
    end

    it "has metadata" do
      expect(government_presenter.page_metadata.any?).to be true
    end

    it "has people, organisations, and working groups in the from metadata" do
      from = government_presenter.page_metadata[:from].map(&:title)
      expect(from).to include("George Dough", "Department for Work and Pensions", "Medical Advisory Group")
    end
  end

  describe "national applicability" do
    it "has applicable nations in the metadata if it is only applicable to some nations" do
      applies_to = national_applicability_presenter.page_metadata[:other]["Applies to"]
      expect(applies_to).to include("England", "Northern Ireland", "Scotland", "Wales")
    end

    it "has no applicable nations in the metadata if it applies to all nations" do
      metadata = government_presenter.page_metadata
      expect(metadata).not_to have_key(:other)
    end

    it "sets rel='external' for an external link" do
      expect(national_applicability_presenter.page_metadata[:other]["Applies to"].include?('rel="external"')).to be true
    end

    it "doesn't set rel='external' for an internal link" do
      expect(national_applicability_with_internal_policies_presenter.page_metadata[:other]["Applies to"].include?('rel="external"')).to be false
    end
  end

  describe "a minimal policy content item" do
    it "doesn't have any page meta data" do
      expect(minimal_policy_presenter.page_metadata.any?).to be false
    end
  end
end
