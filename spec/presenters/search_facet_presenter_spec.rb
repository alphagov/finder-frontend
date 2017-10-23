require "spec_helper"

RSpec.describe SearchFacetPresenter do
  it "return an appropriate hash" do
    facet = SearchFacetPresenter.new({
      "options" => [{
        "value" => {
          "slug" => "department-for-education",
          "title" => "Department for Education"
        },
        "documents" => 1114
      }]
    }, ['department-for-education'])
    expect(facet.to_hash[:any?]).to eq(true)
    expect(facet.to_hash[:options][0][:slug]).to eq('department-for-education')
    expect(facet.to_hash[:options][0][:title]).to eq('Department for Education')
    expect(facet.to_hash[:options][0][:count]).to eq('1,114')
    expect(facet.to_hash[:options][0][:checked]).to be_truthy
  end

  it "work out which items are checked" do
    facet = SearchFacetPresenter.new({
      "options" => [{
        "value" => {
          "slug" => "department-for-education",
          "title" => "Department for Education"
        },
        "documents" => 1114
      }, {
        "value" => {
          "slug" => "department-for-transport",
          "title" => "Department for Transport"
        },
        "documents" => 1114
      }]
    }, ['department-for-education'])
    expect(facet.to_hash[:options][0][:slug]).to eq('department-for-education')
    expect(facet.to_hash[:options][0][:checked]).to be_truthy
    expect(facet.to_hash[:options][1][:slug]).to eq('department-for-transport')
    expect(facet.to_hash[:options][1][:checked]).to be_falsy
  end
end
