require 'gds_api/finder_api'

class FinderApi
  # This class will no longer be necessary when finder schema comes from the api

  attr_reader :api

  def initialize
    @api = GdsApi::FinderApi.new(Plek.current.find('finder-api'))
  end

  def get_finder(slug)
    JSON.parse(File.open('public/schema.json').read)
  end

  def get_documents(slug, params)
    api.get_documents(slug, params)
  end
end
