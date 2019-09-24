require "spec_helper"

RSpec.describe MetadataPresenter do
  subject(:presenter) { described_class.new(raw_metadata) }

  let(:raw_metadata) {
    [
      { id: "case-state", name: "Case state", value: "Open", type: "text" },
      { id: "opened-date", name: "Opened date", value: "2006-7-14", type: "date" },
      { id: "case-type", name: "Case type", value: "CA98 and civil cartels", type: "text" },
    ]
  }
  let(:formatted_metadata) {
    [
      { id: "case-state", label: "Case state", value: "Open", is_text: true, labels: nil },
      { label: "Opened date", is_date: true, machine_date: "2006-07-14", human_date: "14 July 2006" },
      { id: "case-type", label: "Case type", value: "CA98 and civil cartels", is_text: true, labels: nil },
    ]
  }

  describe "#present" do
    it "presents the metadata" do
      expect(subject.present).to eq(formatted_metadata)
    end
  end
end
