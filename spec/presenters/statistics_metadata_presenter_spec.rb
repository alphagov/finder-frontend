require "spec_helper"

RSpec.describe StatisticsMetadataPresenter do
  let(:raw_metadata_announcement) do
    [
      { name: "Updated", value: "2000-01-02T13:54:00.000+01:00", type: "date" },
      { name: "Release date", value: "2004-05-06T09:30:00.000+01:00", type: "date" },
    ]
  end

  let(:raw_metadata_published) do
    [
      { name: "Updated", value: "2000-01-02T13:54:00.000+01:00", type: "date" },
    ]
  end

  let(:formatted_metadata_announcement) do
    [
      { label: "Release date", is_date: true, machine_date: "2004-05-06", human_date: "6 May 2004" },
    ]
  end

  let(:formatted_metadata_published) do
    [
      { label: "Updated", is_date: true, machine_date: "2000-01-02", human_date: "2 January 2000" },
    ]
  end

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
