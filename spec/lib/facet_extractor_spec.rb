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

  context 'with facet_values in links' do
    let(:finder) do
      {
        links: {
          facet_group: {
            links: {
              facets: [
                title: 'Sector / Business Area',
                details: {
                  key: 'sector_business_area'
                },
                links: {
                  facet_values: [
                    
                  ]
                }
              ]
            }
          }
        }
      }
    end
  end
end
