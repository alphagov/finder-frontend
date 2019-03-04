class RedirectionController < ApplicationController
  def announcements
    parameters = { keywords: params['keywords'],
                  level_one_taxon: params['taxons'].try(:first),
                  level_two_taxon: params['subtaxons'].try(:first),
                  people: params['people'],
                  organisations: params['departments'],
                  world_locations: params['world_locations'],
                  public_timestamp: { from: params['from_date'], to: params['to_date'] }.compact.presence }
    redirect_to(finder_path('news-and-communications', params: parameters))
  end
end
