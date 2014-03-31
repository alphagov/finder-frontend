require 'gds_api/finder_api'

module FinderFrontend
  def self.finder_api
    @finder_api ||= GdsApi::FinderApi.new(Plek.current.find('finder-api'))
  end
end
