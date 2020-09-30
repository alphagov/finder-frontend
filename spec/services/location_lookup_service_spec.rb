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

      expected_data = [
        {
          gss: "E01000123",
          area_name: "Coruscant Planetary Council",
          country: "England",
        },
        {
          gss: "E02000456",
          area_name: "Galactic Empire",
          country: "England",
        },
      ]

      expect(described_class.new(postcode).data).to eq(expected_data)
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

      expected_data = [
        {
          gss: "E01000123",
          area_name: "Coruscant Planetary Council",
          country: "England",
        },
      ]

      expect(described_class.new(postcode).data).to eq(expected_data)
    end

    it "returns nothing if the postcode isn't found" do
      postcode = "E18QS"
      stub_mapit_does_not_have_a_postcode(postcode)

      expect(described_class.new(postcode).data).to eq([])
    end
  end
end
