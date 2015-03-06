require 'spec_helper'

RSpec.describe FinderPresenter do
  include GovukContentSchemaExamples

  subject(:presenter) { described_class.new(content_item) }

  let(:government_presenter) { described_class.new(government_finder_content_item) }

  let(:content_item) {
    dummy_http_response = double("net http response",
      code: 200,
      body: govuk_content_schema_example('finder').to_json,
      headers: {}
    )
    GdsApi::Response.new(dummy_http_response).to_ostruct
  }

  let(:government_finder_content_item) {
    dummy_http_response = double("net http response",
      code: 200,
      body: govuk_content_schema_example('finder').merge("base_path" => "/government/policies/a-finder").to_json,
      headers: {}
    )
    GdsApi::Response.new(dummy_http_response).to_ostruct
  }

  describe "facets" do
    it "returns the correct facets" do
      subject.facets.to_a.select{ |f| f.type == "date" }.length.should == 1
      subject.facets.to_a.select{ |f| f.type == "text" }.length.should == 3
      subject.facet_keys.should =~ %w{place_of_origin date_of_introduction walk_type creator}
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

  describe "a government finder" do
    it "sets the government flag" do
      government_presenter.government?.should == true
    end

    it "exposes the government_content_section" do
      government_presenter.government_content_section.should == "policies"
    end
  end

end
