require "spec_helper"

describe RedirectionController, type: :controller do
  include TaxonomySpecHelper

  describe "#announcements" do
    it "redirects to the news-and-comms page" do
      get :announcements
      expect(response).to redirect_to finder_path("search/news-and-communications")
    end
    it "passes on a set of params" do
      get :announcements, params: {
        keywords: %w[one two],
        taxons: %w[one],
        subtaxons: %w[two],
        people: %w[one two],
        departments: %w[one two],
        world_locations: %w[one two],
        from_date: "01/01/2014",
        to_date: "01/01/2014",
      }
      expect(response).to redirect_to finder_path("search/news-and-communications", params: {
        keywords: %w[one two],
        level_one_taxon: "one",
        level_two_taxon: "two",
        people: %w[one two],
        organisations: %w[one two],
        world_locations: %w[one two],
        public_timestamp: { from: "01/01/2014", to: "01/01/2014" },
      })
    end
    it "redirects to the atom feed" do
      get :announcements, params: { keywords: %w[one two] }, format: :atom
      expect(response).to redirect_to finder_path("search/news-and-communications", format: :atom, params: { keywords: %w[one two] })
    end
  end

  describe "#publications" do
    let(:received_params) {
      {
        keywords: %w[one two],
        taxons: %w[one],
        subtaxons: %w[two],
        departments: %w[one two],
        world_locations: %w[one two],
        from_date: "01/01/2014",
        to_date: "01/01/2014",
      }
    }

    let(:converted_params) {
      {
        keywords: %w[one two],
        level_one_taxon: "one",
        level_two_taxon: "two",
        organisations: %w[one two],
        world_locations: %w[one two],
        public_timestamp: { from: "01/01/2014", to: "01/01/2014" },
      }
    }

    it "redirects to the all page by default" do
      get :publications
      expect(response).to redirect_to finder_path("search/all")
    end
    it "passes on a set of params" do
      get :publications, params: received_params
      expect(response).to redirect_to finder_path("search/all", params: converted_params)
    end
    it "redirects when consultations is selected" do
      get :publications, params: received_params.merge(publication_filter_option: "consultations")
      expect(response).to redirect_to finder_path(
        "search/policy-papers-and-consultations",
        params: converted_params.merge(content_store_document_type: %w[open_consultations closed_consultations]),
      )
    end
    it "redirects when closed-consultations is selected" do
      get :publications, params: received_params.merge(publication_filter_option: "closed-consultations")
      expect(response).to redirect_to finder_path(
        "search/policy-papers-and-consultations",
        params: converted_params.merge(content_store_document_type: "closed_consultations"),
      )
    end
    it "redirects when open-consultations is selected" do
      get :publications, params: received_params.merge(publication_filter_option: "open-consultations")
      expect(response).to redirect_to finder_path(
        "search/policy-papers-and-consultations",
        params: converted_params.merge(content_store_document_type: "open_consultations"),
      )
    end
    it "redirects when foi-releases is selected" do
      get :publications, params: received_params.merge(publication_filter_option: "foi-releases")
      expect(response).to redirect_to finder_path(
        "search/transparency-and-freedom-of-information-releases",
        params: converted_params,
      )
    end
    it "redirects when transparency-data is selected" do
      get :publications, params: received_params.merge(publication_filter_option: "transparency-data")
      expect(response).to redirect_to finder_path(
        "search/transparency-and-freedom-of-information-releases",
        params: converted_params,
      )
    end
    it "redirects when guidance is selected" do
      get :publications, params: received_params.merge(publication_filter_option: "guidance")
      expect(response).to redirect_to finder_path(
        "search/guidance-and-regulation",
        params: converted_params,
      )
    end
    it "redirects when policy-papers is selected" do
      get :publications, params: received_params.merge(publication_filter_option: "policy-papers")
      expect(response).to redirect_to finder_path(
        "search/policy-papers-and-consultations",
        params: converted_params.merge(content_store_document_type: "policy_papers"),
      )
    end
    it "redirects when forms is selected" do
      get :publications, params: received_params.merge(publication_filter_option: "forms")
      expect(response).to redirect_to finder_path(
        "search/services",
        params: converted_params,
      )
    end
    it "redirects when research-and-analysis is selected" do
      get :publications, params: received_params.merge(publication_filter_option: "research-and-analysis")
      expect(response).to redirect_to finder_path(
        "search/research-and-statistics",
        params: converted_params.merge(content_store_document_type: "research"),
      )
    end
    it "redirects when statistics is selected" do
      get :publications, params: received_params.merge(publication_filter_option: "statistics")
      expect(response).to redirect_to finder_path(
        "search/research-and-statistics",
        params: converted_params,
      )
    end
    it "redirects to the atom feed" do
      get :publications, params: { keywords: %w[one two] }, format: :atom
      expect(response).to redirect_to finder_path("search/all", format: :atom, params: { keywords: %w[one two] })
    end
  end

  describe "#published_statistics" do
    it "redirects to the statistics page" do
      get :published_statistics
      expect(response).to redirect_to finder_path("search/statistics")
    end
    it "passes on a set of params" do
      get :published_statistics, params: {
        keywords: %w[one two],
        taxons: %w[one],
        departments: %w[one two],
        from_date: "01/01/2014",
        to_date: "01/01/2014",
      }
      expect(response).to redirect_to finder_path("search/statistics", params: {
        keywords: %w[one two],
        level_one_taxon: "one",
        organisations: %w[one two],
        public_timestamp: { from: "01/01/2014", to: "01/01/2014" },
      })
    end
    it "redirects to the atom feed" do
      get :published_statistics, params: { keywords: %w[one two] }, format: :atom
      expect(response).to redirect_to finder_path("search/statistics", format: :atom, params: { keywords: %w[one two] })
    end
  end

  describe "#upcoming_statistics" do
    it "redirects to the statistics page" do
      get :upcoming_statistics
      expect(response).to redirect_to finder_path("search/statistics", params: { content_store_document_type: :statistics_upcoming })
    end
    it "passes on a set of params" do
      get :upcoming_statistics, params: {
        keywords: %w[one two],
        topics: %w[one],
        organisations: %w[one two],
        from_date: "01/01/2014",
        to_date: "01/01/2014",
      }
      expect(response).to redirect_to finder_path("search/statistics", params: {
        keywords: %w[one two],
        level_one_taxon: "one",
        organisations: %w[one two],
        content_store_document_type: :statistics_upcoming,
        public_timestamp: { from: "01/01/2014", to: "01/01/2014" },
      })
    end
    it "redirects to the atom feed" do
      get :upcoming_statistics, params: { keywords: %w[one two] }, format: :atom
      expect(response).to redirect_to finder_path("search/statistics", format: :atom, params: { keywords: %w[one two], content_store_document_type: :statistics_upcoming })
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
end
