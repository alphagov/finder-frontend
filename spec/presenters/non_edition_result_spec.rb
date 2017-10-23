require "spec_helper"

RSpec.describe NonEditionResult do
  it "return document_type as the format" do
    result = NonEditionResult.new(
      SearchParameters.new({}),
              "document_type" => "manual_section",
    )

    expect(result.format).to eq("manual_section")
  end

  it "include a humanized document_type in metadata" do
    result = NonEditionResult.new(
      SearchParameters.new({}),
              "document_type" => "manual_section",
    )

    expect(result.metadata).to include("Manual section")
  end

  it "use a custom humanized document_type form for special cases" do
    result = NonEditionResult.new(
      SearchParameters.new({}),
              "document_type" => "cma_case",
    )

    expect(result.metadata).to include("CMA case")
  end

  it "include public_timestamp date in metadata" do
    result = NonEditionResult.new(
      SearchParameters.new({}),
              "document_type" => "cma_case",
        "public_timestamp" => "2014-12-23T12:34:56",
    )

    expect(result.metadata).to include("23 December 2014")
  end

  it "include organisations in metadata" do
    result = NonEditionResult.new(
      SearchParameters.new({}),
              "document_type" => "manual",
        "organisations" => [
          {
            "slug" => "home-office",
            "title" => "Home Office",
          },
          {
            "slug" => "uk-visas-and-immigration",
            "title" => "UK Visas and Immigration",
            "acronym" => "UKVI",
          },
        ],
    )

    expect(result.metadata).to include(
      "Home Office, <abbr title='UK Visas and Immigration'>UKVI</abbr>"
    )
  end
end
