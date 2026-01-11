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
    before do
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

    it "copes with incorrect types being passed as parameters" do
      get :redirect_latest, params: {
        departments: { "wrong": %w[department-of-magic] },
      }
      expect(response).to redirect_to finder_path("search/all",
                                                  params: { order: "updated-newest" })
    end
  end

  describe "#redirect_consultations" do
    it "redirects to /search/policy-papers-and-consultations retaining level one and two taxons and setting content-store-document-type" do
      get :redirect_consultations, params: {
        topics: "magic-competition",
        subtaxons: "potions",
        content_store_document_type: %w[open_consultations],
      }
      expect(response).to redirect_to finder_path("search/policy-papers-and-consultations",
                                                  params: { order: "updated-newest",
                                                            level_one_taxon: "magic-competition",
                                                            level_two_taxon: "potions",
                                                            content_store_document_type: %w[open_consultations closed_consultations] })
    end

    it "redirects to /search/policy-papers-and-consultations retaining world locations and setting content-store-document-type" do
      get :redirect_consultations, params: {
        world_locations: %w[hogwarts],
        content_store_document_type: %w[open_consultations],
      }
      expect(response).to redirect_to finder_path("search/policy-papers-and-consultations",
                                                  params: { order: "updated-newest",
                                                            world_locations: %w[hogwarts],
                                                            content_store_document_type: %w[open_consultations closed_consultations] })
    end

    it "redirects to /search/policy-papers-and-consultations replacing departments with organisations and setting content-store-document-type" do
      get :redirect_consultations, params: {
        departments: %w[ministry_of_magic],
        content_store_document_type: %w[open_consultations],
      }
      expect(response).to redirect_to finder_path("search/policy-papers-and-consultations",
                                                  params: { order: "updated-newest",
                                                            organisations: %w[ministry_of_magic],
                                                            content_store_document_type: %w[open_consultations closed_consultations] })
    end
  end

  describe "#redirect_statistics_announcements" do
    it "redirects to /search/research-and-statistics" do
      get :redirect_statistics_announcements, params: {
        topics: "magic-competition",
        keywords: %w[harry-potter],
        organisations: %w[ministry-of-magic],
        from_date: "01/01/2014",
        to_date: "01/01/2014",
      }
      expect(response).to redirect_to finder_path("search/research-and-statistics",
                                                  params: { content_store_document_type: "upcoming_statistics",
                                                            keywords: %w[harry-potter],
                                                            level_one_taxon: "magic-competition",
                                                            organisations: %w[ministry-of-magic],
                                                            public_timestamp: {
                                                              from: "01/01/2014",
                                                              to: "01/01/2014",
                                                            } })
    end
  end
end
