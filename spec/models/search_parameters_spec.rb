# typed: false
require "spec_helper"

RSpec.describe SearchParameters do
  def search_params(params = {})
    described_class.new(ActionController::Parameters.new(params))
  end

  context '#count' do
    it 'default to default page size' do
      params = search_params

      expect(params.count).to eq(described_class::DEFAULT_RESULTS_PER_PAGE)
    end

    it 'default to default page size when count < 1' do
      params = search_params(count: -50)

      expect(params.count).to eq(described_class::DEFAULT_RESULTS_PER_PAGE)
    end

    it 'allow at most a hundred results' do
      params = search_params(count: 10_000)

      expect(params.count).to eq(100)
    end
  end

  context '#suggest' do
    it "requests the spelling suggester by default" do
      params = search_params

      expect(params.rummager_parameters[:suggest]).to eq("spelling")
    end
  end

  context '#start' do
    it 'start at 0 if start < 1' do
      params = search_params(start: -1)

      expect(params.start).to eq(0)
    end
  end

  context "#filter_organisations" do
    it "pass on filter_organisations" do
      params = search_params("filter_organisations" => ['ministry-of-silly-walks'])

      expect(params.rummager_parameters[:filter_organisations]).to eq(['ministry-of-silly-walks'])
    end

    it "pass on filter_organisations as an array if provided as single value" do
      params = search_params("filter_organisations" => 'ministry-of-silly-walks')

      expect(params.rummager_parameters[:filter_organisations]).to eq(['ministry-of-silly-walks'])
    end
  end

  context "#search_term" do
    it "truncates a too-long search query" do
      max_length = SearchQueryBuilder::MAX_QUERY_LENGTH
      long_query = "a" * max_length
      params = search_params("q" => "#{long_query}1234567890")
      expect(params.rummager_parameters[:q]).to eq(long_query)
    end
  end
end
