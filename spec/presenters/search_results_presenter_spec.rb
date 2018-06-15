require "spec_helper"

RSpec.describe SearchResultsPresenter do
  let(:view_content) { double(:view_content, render: 'pagination_html') }

  def search_params(params)
    SearchParameters.new(ActionController::Parameters.new(params))
  end

  it "return an appropriate hash" do
    results = SearchResultsPresenter.new({
      "total" => 1,
      "results" => [{ "index" => "mainstream" }],
      "facets" => {}
    }, search_params(q: 'my-query'), view_content)

    expect(results.to_hash[:query]).to eq('my-query')
    expect(results.to_hash[:result_count]).to eq(1)
    expect(results.to_hash[:result_count_string]).to eq('1 result')
    expect(results.to_hash[:results_any?]).to eq(true)
  end

  it "return an entry for a facet" do
    results = SearchResultsPresenter.new({
      "results" => [],
      "facets" => {
        "organisations" => {
          "options" => [{
            "value" => {
              "link" => "/government/organisations/department-for-education",
              "title" => "Department for Education"
            },
            "documents" => 114
          }]
        }
      }
    }, search_params(q: 'my-query'), view_content)

    expect(results.to_hash[:filter_fields].length).to eq(1)
    expect(results.to_hash[:filter_fields][0][:field]).to eq("organisations")
    expect(results.to_hash[:filter_fields][0][:field_title]).to eq("Organisations")
    expect(results.to_hash[:filter_fields][0][:options][:options].length).to eq(1)
    expect(results.to_hash[:filter_fields][0][:options][:options][0][:title]).to eq("Department for Education")
  end

  context 'grouping' do
    it "not have metadata for group results" do
      results = SearchResultsPresenter.new({
        "total" => 1,
        "results" => [{ "document_type" => "group" }],
        "facets" => {}
      }, search_params(q: 'my-query'), view_content)
      rlist = results.to_hash[:results]
      expect(rlist.size).to eq(1)
      expect(rlist[0][:metadata]).to be_nil
      expect(rlist[0][:metadata_any?]).to be_falsy
    end
  end
end
