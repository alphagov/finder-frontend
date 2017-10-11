# coding: utf-8
require "spec_helper"

RSpec.describe GovernmentResult do
  it "report a lack of location field as no locations" do
    result = GovernmentResult.new(SearchParameters.new({}), {})
    expect(result.metadata).to be_empty
  end

  it "report an empty list of locations as no locations" do
    result = GovernmentResult.new(SearchParameters.new({}), "world_locations" => [])
    expect(result.metadata).to be_empty
  end

  it "display a single world location" do
    france = { "title" => "France", "slug" => "france" }
    result = GovernmentResult.new(SearchParameters.new({}), "world_locations" => [france])
    expect(result.metadata[0]).to eq("France")
  end

  it "not display individual locations when there are several" do
    france = { "title" => "France", "slug" => "france" }
    spain = { "title" => "Spain", "slug" => "spain" }
    result = GovernmentResult.new(SearchParameters.new({}), "world_locations" => [france, spain])
    expect(result.metadata[0]).to eq("multiple locations")
  end

  it "not display locations when there is only a slug present" do
    united_kingdom = { "slug" => "united_kingdom" }
    result = GovernmentResult.new(SearchParameters.new({}), "world_locations" => [united_kingdom])
    expect(result.metadata).to be_empty
  end

  it "return valid metadata" do
    result = GovernmentResult.new(SearchParameters.new({}), "public_timestamp" => "2014-10-14",
      "display_type" => "my-display-type",
      "organisations" => [{ "slug" => "org-1" }],
      "world_locations" => [{ "title" => "France", "slug" => "france" }])
    expect(result.metadata).to eq(['14 October 2014', 'my-display-type', 'org-1', 'France'])
  end

  it "return format for corporate information pages in metadata" do
    result = GovernmentResult.new(SearchParameters.new({}), "format" => "corporate_information")
    expect(result.metadata).to eq(['Corporate information'])
  end

  it "return only display type for corporate information pages if it is present in metadata" do
    result = GovernmentResult.new(SearchParameters.new({}), "display_type" => "my-display-type",
      "format" => "corporate_information")
    expect(result.metadata).to eq(["my-display-type"])
  end

  it "not return sections for deputy prime ministers office" do
    result = GovernmentResult.new(SearchParameters.new({}), "format" => "organisation",
      "link" => "/government/organisations/deputy-prime-ministers-office")
    expect(result.sections).to be_nil
  end

  it "return sections for some format types" do
    params = SearchParameters.new({})
    minister_results               = GovernmentResult.new(params, "format" => "minister")
    organisation_results           = GovernmentResult.new(params, "format" => "organisation")
    person_results                 = GovernmentResult.new(params, "format" => "person")
    worldwide_organisation_results = GovernmentResult.new(params, "format" => "worldwide_organisation")
    mainstream_results             = GovernmentResult.new(params, "format" => "mainstream")

    expect(minister_results.sections.length).to eq(2)
    expect(organisation_results.sections).to be_nil
    expect(person_results.sections.length).to eq(2)
    expect(worldwide_organisation_results.sections.length).to eq(2)

    expect(mainstream_results.sections).to be_nil
  end

  it "return sections in correct format" do
    minister_results = GovernmentResult.new(SearchParameters.new({}), "format" => "minister")

    expect(minister_results.sections.first.keys).to eq([:hash, :title])
  end

  it "have a government name when in history mode" do
    result = GovernmentResult.new(SearchParameters.new({}), "is_historic" => true,
      "government_name" => "XXXX to YYYY Example government")
    expect(result).to be_historic
    expect(result.government_name).to eq("XXXX to YYYY Example government")
  end

  it "have a government name when not in history mode" do
    result = GovernmentResult.new(SearchParameters.new({}), "is_historic" => false,
      "government_name" => "XXXX to YYYY Example government")
    expect(result).not_to be_historic
    expect(result.government_name).to eq("XXXX to YYYY Example government")
  end
end
