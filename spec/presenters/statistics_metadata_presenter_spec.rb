require "spec_helper"

RSpec.describe StatisticsMetadataPresenter do
  let(:raw_metadata_announcement) {
    [
      { name: "Updated", value: "2000-01-02T13:54:00.000+01:00", type: "date" },
      { name: "Release date", value: "2004-05-06T09:30:00.000+01:00", type: "date" },
    ]
  }

  let(:raw_metadata_published) {
    [
      { name: "Updated", value: "2000-01-02T13:54:00.000+01:00", type: "date" },
    ]
  }

  let(:formatted_metadata_announcement) {
    [
      { label: "Release date", is_date: true, machine_date: "2004-05-06", human_date: "6 May 2004" },
    ]
  }

  let(:formatted_metadata_published) {
    [
      { label: "Updated", is_date: true, machine_date: "2000-01-02", human_date: "2 January 2000" },
    ]
  }

  describe "#present" do
    context "when both release date and updated dates" do
      it "formats the metadata" do
        presenter = described_class.new(raw_metadata_announcement)
        expect(presenter.present).to eq(formatted_metadata_announcement)
      end
    end

    context "when only updated date" do
      it "formats the metadata" do
        presenter = described_class.new(raw_metadata_published)
        expect(presenter.present).to eq(formatted_metadata_published)
      end
    end
  end
end
