require "spec_helper"
require "gds_api/test_helpers/mapit"

RSpec.describe LocationLookupService do
  include GdsApi::TestHelpers::Mapit

  describe "#data" do
    it "returns location data" do
      postcode = "E18QS"
      areas = [
        {
          "ons" => "01",
          "gss" => "E01000123",
          "govuk_slug" => "test-one",
          "name" => "Coruscant Planetary Council",
          "type" => "LBO",
          "country_name" => "England",
        },
        {
          "ons" => "02",
          "gss" => "E02000456",
          "govuk_slug" => "test-two",
          "name" => "Galactic Empire",
          "type" => "GLA",
          "country_name" => "England",
        },
      ]
      stub_mapit_has_a_postcode_and_areas(postcode, [], areas)

      data = described_class.new(postcode).data

      expect(data.size).to eq(2)
      expect(data.first).to be_a(MapitPostcodeResponse)
      expect(data.first.gss).to eq("E01000123")

      expect(data.second).to be_a(MapitPostcodeResponse)
      expect(data.second.gss).to eq("E02000456")
    end

    it "only returns locations with a gss code" do
      postcode = "E18QS"
      areas = [
        {
          "ons" => "01",
          "gss" => "E01000123",
          "govuk_slug" => "test-one",
          "name" => "Coruscant Planetary Council",
          "type" => "LBO",
          "country_name" => "England",
        },
        {
          "govuk_slug" => "test-two",
          "name" => "Galactic Empire",
          "type" => "GLA",
          "country_name" => "England",
        },
      ]
      stub_mapit_has_a_postcode_and_areas(postcode, [], areas)

      data = described_class.new(postcode).data

      expect(data.size).to eq(1)
      expect(data.first).to be_a(MapitPostcodeResponse)
      expect(data.first.gss).to eq("E01000123")
    end

    it "returns nothing if the postcode isn't found" do
      postcode = "E18QS"
      stub_mapit_does_not_have_a_postcode(postcode)

      expect(described_class.new(postcode).data).to eq([])
    end
  end
end
