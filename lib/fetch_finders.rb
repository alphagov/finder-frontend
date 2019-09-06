class FetchFinders
  def self.from_search_api
    GovukStatsd.time("fetch_finders.from_search_api.request_time") do
      Services.rummager.search(
        filter_rendering_app: 'finder-frontend',
        fields: %w(link),
        count: 1500,
      ).dig('results')
    end
  end
end
