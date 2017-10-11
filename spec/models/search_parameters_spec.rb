require "spec_helper"

RSpec.describe SearchParameters do
  context '#count' do
    it 'default to default page size' do
      params = described_class.new({})

      expect(params.count).to eq(described_class::DEFAULT_RESULTS_PER_PAGE)
    end

    it 'default to default page size when count < 1' do
      params = described_class.new(count: -50)

      expect(params.count).to eq(described_class::DEFAULT_RESULTS_PER_PAGE)
    end

    it 'allow at most a hundred results' do
      params = described_class.new(count: 10_000)

      expect(params.count).to eq(100)
    end
  end

  context '#suggest' do
    it "requests the spelling suggester by default" do
      params = described_class.new({})

      expect(params.rummager_parameters[:suggest]).to eq("spelling")
    end
  end

  context '#start' do
    it 'start at 0 if start < 1' do
      params = described_class.new(start: -1)

      expect(params.start).to eq(0)
    end
  end

  context "#filter_organisations" do
    it "pass on filter_organisations" do
      params = described_class.new("filter_organisations" => ['ministry-of-silly-walks'])

      expect(params.rummager_parameters[:filter_organisations]).to eq(['ministry-of-silly-walks'])
    end

    it "pass on filter_organisations as an array if provided as single value" do
      params = described_class.new("filter_organisations" => 'ministry-of-silly-walks')

      expect(params.rummager_parameters[:filter_organisations]).to eq(['ministry-of-silly-walks'])
    end
  end
end
