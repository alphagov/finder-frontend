require "gds_api/mapit"
require "plek"

module FinderFrontend
  mattr_accessor :mapit_api
end

FinderFrontend.mapit_api = GdsApi::Mapit.new(Plek.new.find("mapit"))
