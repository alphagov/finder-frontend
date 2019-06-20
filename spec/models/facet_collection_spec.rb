# typed: false
require 'spec_helper'
require "helpers/taxonomy_spec_helper"

describe FacetCollection do
  include TaxonomySpecHelper

  before do
    topic_taxonomy_has_taxons([
                                {
                                  content_id: "123",
                                  title: "transport"
                                }
                              ])
  end

  before { Rails.cache.clear }
  after { Rails.cache.clear }

  context "with facets with values" do
    it "should accept a hash of key/value pairs, and set the facet values for each" do
      facet_hashes = [
        {
          "key" => "organisations",
          "name" => "Organisation",
          "type" => "text",
          "filterable" => true,
        },
        {
          "keys" => %w[level_one_taxon level_two_taxon],
          "name" => "topic",
          "type" => "taxon",
          "filterable" => true,
        },
      ]

      values = {
        organisations: "org",
        "level_one_taxon" => "transport"
      }
      collection = FacetCollection.new(facet_hashes, values)
      expect(collection.facets).to match_array [be_instance_of(OptionSelectFacet), be_instance_of(TaxonFacet)]
      expect(collection.facets.first.value).to eq(%w[org])
      expect(collection.facets.second.topics).to match_array([include(text: "transport"),
                                                              include(text: 'All topics')])
    end
  end
end
