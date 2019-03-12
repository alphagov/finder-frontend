require 'spec_helper'

describe RedirectionController, type: :controller do
  describe '#announcements' do
    it "redirects to the news-and-comms page" do
      get :announcements
      expect(response).to redirect_to finder_path('search/news-and-communications')
    end
    it 'passes on a set of params' do
      get :announcements, params: {
        keywords: %w[one two],
        taxons: %w[one],
        subtaxons: %w[two],
        people: %w[one two],
        departments: %w[one two],
        world_locations: %w[one two],
        from_date: '01/01/2014',
        to_date: '01/01/2014'
      }
      expect(response).to redirect_to finder_path('search/news-and-communications', params: {
        keywords: %w[one two],
        level_one_taxon: 'one',
        level_two_taxon: 'two',
        people: %w[one two],
        organisations: %w[one two],
        world_locations: %w[one two],
        public_timestamp: { from: '01/01/2014', to: '01/01/2014' }
      })
    end
    it 'redirects to the atom feed' do
      get :announcements, params: { keywords: %w[one two] }, format: :atom
      expect(response).to redirect_to finder_path('search/news-and-communications', format: :atom, params: { keywords: %w[one two] })
    end
  end

  describe '#publications' do
    it "redirects to the all page" do
      get :publications
      expect(response).to redirect_to finder_path('search/all')
    end
    it 'passes on a set of params' do
      get :publications, params: {
        keywords: %w[one two],
        taxons: %w[one],
        subtaxons: %w[two],
        departments: %w[one two],
        world_locations: %w[one two],
        from_date: '01/01/2014',
        to_date: '01/01/2014'
      }
      expect(response).to redirect_to finder_path('search/all', params: {
        keywords: %w[one two],
        level_one_taxon: 'one',
        level_two_taxon: 'two',
        organisations: %w[one two],
        world_locations: %w[one two],
        public_timestamp: { from: '01/01/2014', to: '01/01/2014' }
      })
    end
    it 'redirects to the atom feed' do
      get :publications, params: { keywords: %w[one two] }, format: :atom
      expect(response).to redirect_to finder_path('search/all', format: :atom, params: { keywords: %w[one two] })
    end
  end

  describe '#published_statistics' do
    it "redirects to the statistics page" do
      get :published_statistics
      expect(response).to redirect_to finder_path('search/statistics')
    end
    it 'passes on a set of params' do
      get :published_statistics, params: {
        keywords: %w[one two],
        taxons: %w[one],
        departments: %w[one two],
        from_date: '01/01/2014',
        to_date: '01/01/2014'
      }
      expect(response).to redirect_to finder_path('search/statistics', params: {
        keywords: %w[one two],
        level_one_taxon: 'one',
        organisations: %w[one two],
        public_timestamp: { from: '01/01/2014', to: '01/01/2014' }
      })
    end
    it 'redirects to the atom feed' do
      get :published_statistics, params: { keywords: %w[one two] }, format: :atom
      expect(response).to redirect_to finder_path('search/statistics', format: :atom, params: { keywords: %w[one two] })
    end
  end

  describe '#upcoming_statistics' do
    it "redirects to the statistics page" do
      get :upcoming_statistics
      expect(response).to redirect_to finder_path('search/statistics', params: { content_store_document_type: :statistics_upcoming })
    end
    it 'passes on a set of params' do
      get :upcoming_statistics, params: {
        keywords: %w[one two],
        topics: %w[one],
        organisations: %w[one two],
        from_date: '01/01/2014',
        to_date: '01/01/2014'
      }
      expect(response).to redirect_to finder_path('search/statistics', params: {
        keywords: %w[one two],
        level_one_taxon: 'one',
        organisations: %w[one two],
        content_store_document_type: :statistics_upcoming,
        public_timestamp: { from: '01/01/2014', to: '01/01/2014' }
      })
    end
    it 'redirects to the atom feed' do
      get :upcoming_statistics, params: { keywords: %w[one two] }, format: :atom
      expect(response).to redirect_to finder_path('search/statistics', format: :atom, params: { keywords: %w[one two], content_store_document_type: :statistics_upcoming })
    end
  end
end
