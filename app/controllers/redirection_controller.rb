class RedirectionController < ApplicationController
  def announcements
    respond_to do |format|
      format.html { redirect_to(finder_path('search/news-and-communications', params: convert_common_parameters)) }
      format.atom { redirect_to(finder_path('search/news-and-communications', params: convert_common_parameters, format: :atom)) }
    end
  end

  def publications
    respond_to do |format|
      format.html { redirect_to(finder_path('search/all', params: convert_common_parameters)) }
      format.atom { redirect_to(finder_path('search/all', params: convert_common_parameters, format: :atom)) }
    end
  end

  def published_statistics
    respond_to do |format|
      format.html { redirect_to(finder_path('search/statistics', params: convert_common_parameters)) }
      format.atom { redirect_to(finder_path('search/statistics', params: convert_common_parameters, format: :atom)) }
    end
  end

  def upcoming_statistics
    respond_to do |format|
      format.html { redirect_to(finder_path('search/statistics', params: convert_common_parameters.merge(content_store_document_type: :statistics_upcoming))) }
      format.atom { redirect_to(finder_path('search/statistics', params: convert_common_parameters.merge(content_store_document_type: :statistics_upcoming), format: :atom)) }
    end
  end

private

  def convert_common_parameters
    { keywords: params['keywords'],
      level_one_taxon: params['taxons'].try(:first) || params['topics'].try(:first),
      level_two_taxon: params['subtaxons'].try(:first),
      organisations: params['departments'] || params['organisations'],
      people: params['people'],
      world_locations: params['world_locations'],
      public_timestamp: { from: params['from_date'], to: params['to_date'] }.compact.presence }
  end
end
