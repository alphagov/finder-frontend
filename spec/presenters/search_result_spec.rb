# coding: utf-8
require "spec_helper"

RSpec.describe SearchResult do
  let(:search_params) { SearchParameters.new(ActionController::Parameters.new({})) }

  it "report when no examples are present" do
    result = SearchResult.new(search_params, {}).to_hash
    expect(result[:examples_present?]).to be_falsy
  end

  it "present examples" do
    result = SearchResult.new(
      search_params,
      "examples" => [{ "title" => "An example" }]
    ).to_hash
    expect(result[:examples_present?]).to be_truthy
    expect(result[:examples]).to eq([{ "title" => "An example" }])
  end
end
