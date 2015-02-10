require 'spec_helper'

RSpec.describe FinderPresenter do

  subject(:presenter) { FinderPresenter.new(finder) }

  let(:finder) {
    OpenStruct.new(
      base_path: "/mosw-reports",
      title: "Ministry of Silly Walks reports",
      details: OpenStruct.new(
        facets: [
          OpenStruct.new(
            key: "walk-type",
            name: "Walk type",
            preposition: "of type",
            type: "text",
            filterable: true,
            display_as_result_metadata: true,
            allowed_values: [
              OpenStruct.new(
                key: "backwards",
                label: "Backwards",
              ),
              OpenStruct.new(
                key: "hopscotch",
                label: "Hopscotch",
              ),
              OpenStruct.new(
                key: "start-and-stop",
                label: "Start-and-stop",
              ),
            ]
          ),
          OpenStruct.new(
            key: "place-of-origin",
            name: "Place of origin",
            preposition: "which originated in",
            type: "text",
            filterable: true,
            display_as_result_metadata: true,
            allowed_values: [
              OpenStruct.new(
                key: "england",
                label: "England",
              ),
              OpenStruct.new(
                key: "northern-ireland",
                label: "Northern Ireland",
              ),
              OpenStruct.new(
                key: "scotland",
                label: "Scotland",
              ),
              OpenStruct.new(
                key: "wales",
                label: "Wales",
              ),
            ]
          ),
          OpenStruct.new(
            key: "date-of-introduction",
            name: "Date of introduction",
            short_name: "Introduced",
            type: "date",
            filterable: false,
            display_as_result_metadata: true,
          ),
          OpenStruct.new(
            key: "creator",
            name: "Creator",
            type: "text",
            filterable: false,
            display_as_result_metadata: false,
          )
        ]
      ),
      links: OpenStruct.new(
        organisations: [
          OpenStruct.new(
            title: "Ministry of Silly Walks",
            base_path: "/government/organisations/ministry-of-silly-walks",
          )
        ],
      )
    )
  }

  describe "facets" do
    it "returns the correct facets" do
      subject.facets.to_a.select{ |f| f.type == "date" }.length.should == 1
      subject.facets.to_a.select{ |f| f.type == "text" }.length.should == 3
      subject.facet_keys.should =~ %w{place-of-origin date-of-introduction walk-type creator}
    end

    it "returns the correct filters" do
      subject.filters.length.should == 2
    end

    it "returns the correct metadata" do
      subject.metadata.length.should == 3
    end

    it "returns correct keys for each facet type" do
      subject.date_metadata_keys.should =~ %w{date-of-introduction}
      subject.text_metadata_keys.should =~ %w{place-of-origin walk-type}
    end
  end

  describe "#label_for_metadata_key" do
    it "finds the correct key" do
      subject.label_for_metadata_key("date-of-introduction").should == "Introduced"
    end
  end

end
