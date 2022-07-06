require "spec_helper"

describe RedirectionController, type: :controller do
  include TaxonomySpecHelper

  describe "#redirect_brexit" do
    it "redirects to the same slug with the brexit taxon" do
      get :redirect_brexit, params: {
        slug: "search/random-finder",
      }
      expect(response).to redirect_to finder_path("search/random-finder",
                                                  params: {
                                                    level_one_taxon: ContentItem::BREXIT_CONTENT_ID,
                                                  })
    end

    it "replaces the brexit param with the brexit taxon, overwriting other taxons" do
      get :redirect_brexit, params: {
        "slug" => "any-finder",
        "keywords" => "one two",
        "level_one_taxon" => "one",
        "level_two_taxon" => "two",
        "people" => %w[one two],
        "organisations" => %w[one two],
        "world_locations" => %w[one two],
        "public_timestamp" => { "from" => "01/01/2014", "to" => "01/01/2014" },
        "topical_events" => %w[anything],
      }
      expect(response).to redirect_to finder_path(
        "any-finder", params: {
          keywords: "one two",
          level_one_taxon: ContentItem::BREXIT_CONTENT_ID,
          people: %w[one two],
          organisations: %w[one two],
          world_locations: %w[one two],
          public_timestamp: { from: "01/01/2014", to: "01/01/2014" },
        }
      )
    end
  end

  describe "#redirect_covid" do
    it "redirects to the same slug with the coronavirus taxon" do
      get :redirect_covid, params: {
        slug: "search/random-finder",
      }
      expect(response).to redirect_to finder_path("search/random-finder",
                                                  params: {
                                                    level_one_taxon: "5b7b9532-a775-4bd2-a3aa-6ce380184b6c",
                                                  })
    end

    it "replaces the topical event with the coronavirus taxon, overwriting other taxons" do
      get :redirect_covid, params: {
        "slug" => "any-finder",
        "keywords" => "one two",
        "level_one_taxon" => "one",
        "level_two_taxon" => "two",
        "people" => %w[one two],
        "organisations" => %w[one two],
        "world_locations" => %w[one two],
        "public_timestamp" => { "from" => "01/01/2014", "to" => "01/01/2014" },
        "topical_events" => %w[anything],
      }
      expect(response).to redirect_to finder_path(
        "any-finder", params: {
          keywords: "one two",
          level_one_taxon: "5b7b9532-a775-4bd2-a3aa-6ce380184b6c",
          people: %w[one two],
          organisations: %w[one two],
          world_locations: %w[one two],
          public_timestamp: { from: "01/01/2014", to: "01/01/2014" },
        }
      )
    end
  end

  describe "#advanced_search" do
    before :each do
      Rails.cache.clear
      topic_taxonomy_has_taxons([FactoryBot.build(:level_one_taxon_hash, content_id: "content_id", base_path: "/path/topic")])
    end
    it "redirects to news and comms finder" do
      get :advanced_search, params: { group: "news_and_communications" }
      expect(response).to redirect_to finder_path("search/news-and-communications")
    end
    it "redirects the services finder" do
      get :advanced_search, params: { group: "services" }
      expect(response).to redirect_to finder_path("search/services", params: {})
    end
    it "redirects with a topic parameter, translating the base path to content_id" do
      get :advanced_search, params: { group: "services", topic: "/path/topic" }
      expect(response).to redirect_to finder_path("search/services", params: { topic: "content_id" })
    end
    context "The topic does not exist" do
      it "redirects ignoring the topic" do
        get :advanced_search, params: { group: "services", topic: "/path/does-not-exist" }
        expect(response).to redirect_to finder_path("search/services", params: {})
      end
    end
    context "The group does not exist" do
      it "returns 404" do
        get :advanced_search, params: { group: "does-not-exist", topic: "/path/topic" }
        expect(response.status).to eq(404)
      end
    end
  end

  describe "#redirect_latest" do
    it "redirects to /search/all retaining topical events" do
      get :redirect_latest, params: {
        topical_events: %w[magic-competition],
      }
      expect(response).to redirect_to finder_path("search/all",
                                                  params: {
                                                    order: "updated-newest",
                                                    topical_events: %w[magic-competition],
                                                  })
    end

    it "redirects to /search/all retaining world locations" do
      get :redirect_latest, params: {
        world_locations: %w[hogwarts],
      }
      expect(response).to redirect_to finder_path("search/all",
                                                  params: {
                                                    order: "updated-newest",
                                                    world_locations: %w[hogwarts],
                                                  })
    end

    it "redirects to /search/all replacing departments with organisations" do
      get :redirect_latest, params: {
        departments: %w[department-of-magic],
      }
      expect(response).to redirect_to finder_path("search/all",
                                                  params: {
                                                    order: "updated-newest",
                                                    organisations: %w[department-of-magic],
                                                  })
    end
  end
end
