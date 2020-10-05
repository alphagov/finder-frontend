require "spec_helper"

RSpec.describe LocalRestriction do
  before do
    stub_const("LocalRestriction::FILE_PATH", "spec/fixtures/local-restrictions.yaml")
  end

  let(:restriction) { described_class.new("E08000001") }

  it "returns the area name" do
    expect(restriction.area_name).to eq("Tatooine")
  end

  it "returns the alert level" do
    expect(restriction.alert_level).to eq(4)
  end

  it "returns the guidance" do
    guidance = restriction.guidance
    expect(guidance["label"]).to eq("These are not the restrictions you are looking for")
    expect(guidance["link"]).to eq("guidance/tatooine-local-restrictions")
  end

  it "returns the extra restrictions" do
    expect(restriction.extra_restrictions).to be nil
  end

  it "returns nil values if the gss code doesn't exist" do
    restriction = described_class.new("fake code")
    name = restriction.area_name
    guidance = restriction.guidance
    expect(name).to be nil
    expect(guidance).to be nil
  end

  describe "#start_date" do
    it "returns the start date" do
      expect(restriction.start_date).to eq("01 October 2020".to_date)
    end

    it "allows the start date to be nil" do
      restriction = described_class.new("E08000002")
      expect(restriction.start_date).to be nil
    end
  end

  describe "#end_date" do
    it "returns the end date" do
      expect(restriction.end_date).to eq("02 October 2020".to_date)
    end

    it "allows the end date to be nil" do
      restriction = described_class.new("E08000002")
      expect(restriction.end_date).to be nil
    end
  end
end
