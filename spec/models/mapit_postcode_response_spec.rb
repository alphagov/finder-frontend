require "spec_helper"

RSpec.describe MapitPostcodeResponse do
  let(:location) do
    {
      "codes" => {
        "ons" => "01",
        "gss" => "E01000123",
        "govuk_slug" => "test-one",
      },
      "name" => "Coruscant Planetary Council",
      "type" => "LBO",
      "country_name" => "England",
    }
  end

  it "returns the gss code" do
    expect(described_class.new(location).gss).to eq("E01000123")
  end

  it "returns the area name" do
    expect(described_class.new(location).area_name).to eq("Coruscant Planetary Council")
  end

  it "returns the country" do
    expect(described_class.new(location).country).to eq("England")
  end

  describe "#england?" do
    it "returns true if the country is England" do
      expect(described_class.new(location).england?).to be true
    end
  end

  describe "#scotland?" do
    it "returns true if the country is Scotland" do
      location["country_name"] = "Scotland"

      expect(described_class.new(location).scotland?).to be true
    end
  end

  describe "#wales?" do
    it "returns true if the country is Wales" do
      location["country_name"] = "Wales"

      expect(described_class.new(location).wales?).to be true
    end
  end

  describe "#northern_ireland?" do
    it "returns true if the country is Northern Ireland" do
      location["country_name"] = "Northern Ireland"

      expect(described_class.new(location).northern_ireland?).to be true
    end
  end
end
