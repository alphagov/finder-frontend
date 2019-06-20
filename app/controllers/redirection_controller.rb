# typed: false
require 'publications_routes'

class RedirectionController < ApplicationController
  include PublicationsRoutes
  DEFAULT_PUBLICATIONS_PATH = 'search/all'.freeze

  def announcements
    respond_to do |format|
      format.html { redirect_to(finder_path('search/news-and-communications', params: convert_common_parameters)) }
      format.atom { redirect_to(finder_path('search/news-and-communications', params: convert_common_parameters, format: :atom)) }
    end
  end

  def publications
    respond_to do |format|
      format.html { redirect_to(finder_path(publications_base_path, params: convert_common_parameters.merge(content_store_document_type: set_document_type).compact)) }
      format.atom { redirect_to(finder_path(publications_base_path, params: convert_common_parameters.merge(content_store_document_type: set_document_type).compact, format: :atom)) }
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

  def publications_base_path
    base_path = PUBLICATIONS_ROUTES.dig(params[:publication_filter_option], :base_path)
    base_path || DEFAULT_PUBLICATIONS_PATH
  end

  def set_document_type
    PUBLICATIONS_ROUTES.dig(params[:publication_filter_option], :special_params, :content_store_document_type)
  end

  def convert_common_parameters
    { keywords: params['keywords'],
      level_one_taxon: params['taxons'].try(:first) || params['topics'].try(:first),
      level_two_taxon: params['subtaxons'].try(:first),
      organisations: params['departments'] || params['organisations'],
      people: params['people'],
      world_locations: params['world_locations'],
      public_timestamp: { from: params['from_date'], to: params['to_date'] }.compact.presence }.compact
  end
end
