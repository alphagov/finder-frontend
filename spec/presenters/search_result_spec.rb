# coding: utf-8
require "spec_helper"

RSpec.describe SearchResult do
  it "report when no examples are present" do
    result = SearchResult.new(SearchParameters.new({}), {}).to_hash
    expect(result[:examples_present?]).to be_falsy
  end

  it "present examples" do
    result = SearchResult.new(SearchParameters.new({}),
                              "examples" => [{ "title" => "An example" }]).to_hash
    expect(result[:examples_present?]).to be_truthy
    expect(result[:examples]).to eq([{ "title" => "An example" }])
  end
end
