require "spec_helper"

RSpec.describe "autocomplete API", type: :request do
  let(:search_api_v2) { double(:search_api_v2, autocomplete: autocomplete_response) }

  let(:suggestions) { %w[blue grey red] }
  let(:autocomplete_response) { instance_double(GdsApi::Response, to_hash: { suggestions: }) }

  before do
    allow(Services).to receive(:search_api_v2).and_return(search_api_v2)
  end

  it "returns suggestions from Search API v2" do
    get "/api/search/autocomplete?q=loving+him+was"

    expect(search_api_v2).to have_received(:autocomplete).with("loving him was")
    expect(response).to be_successful
    expect(JSON.parse(response.body)).to eq("suggestions" => suggestions)
  end

  it "fails if the query parameter is missing" do
    get "/api/search/autocomplete"

    expect(response).to have_http_status(:bad_request)
  end
end
