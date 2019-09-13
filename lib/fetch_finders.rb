class FetchFinders
  def self.from_search_api
    GovukStatsd.time("rummager.fetch_finders") do
      Services.rummager.search(
        filter_rendering_app: 'finder-frontend',
        fields: %w(link),
        count: 1500,
      ).dig('results')
    end
  end
end
