require 'spec_helper'

describe FacetExtractor do
  let(:facets) { described_class.new(finder).extract }
  context 'with facets in details' do
    let(:finder) do
      {
        details: {
          facets: [
            { some: 'facet details' },
            { some: 'more facet details' }
          ]
        }
      }.deep_stringify_keys
    end

    it 'returns the facets directly from the finder' do
      expect(facets).to eq([
        { 'some' => 'facet details' },
        { 'some' => 'more facet details' }
      ])
    end
  end
end
