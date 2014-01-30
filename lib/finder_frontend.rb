module FinderFrontend
  def self.finder_api
    @finder_api ||= FinderApi.new
  end
end
