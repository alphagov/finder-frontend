require 'gds_api/rummager'

module FinderFrontend
  def self.get_documents(finder, params)
    FindDocuments.new(
      base_filter: finder.filter.to_h,
      metadata_fields: finder.facet_keys,
      default_order: finder.default_order,
      params: params,
      facets: finder.faceted_filters
    ).call
  end

  class FindDocuments
    def initialize(base_filter:, metadata_fields:, default_order:, params:, facets:)
      @base_filter = base_filter
      @metadata_fields = metadata_fields
      @default_order = default_order || "-public_timestamp"
      @params = params
      @facets = facets
    end

    def call
      rummager_api.unified_search(default_params.merge(massaged_params))
        .to_hash
    end

  private

    attr_reader :base_filter, :metadata_fields, :default_order, :params, :facets

    def rummager_api
      @rummager_api ||= GdsApi::Rummager.new(Plek.new.find('search'))
    end

    def default_params
      {
        "count"  => "1000",
        "fields" => return_fields.join(","),
      }
    end

    def return_fields
      base_return_fields.concat(metadata_fields).uniq
    end

    def base_return_fields
      %w(
        title
        link
        description
        public_timestamp
      )
    end

    def massaged_params
      keyword_param
        .merge(filter_params)
        .merge(order_param)
        .merge(facet_params)
    end

    def keyword_param
      if params.has_key?("keywords")
        {"q" => params.fetch("keywords")}
      else
        {}
      end
    end

    def order_param
      if params.has_key?("keywords")
        {}
      else
        {"order" => default_order}
      end
    end

    def filter_params
      params
        .except("keywords")
        .merge(base_filter)
        .reduce({}) { |memo, (k,v)|
          memo.merge("filter_#{k}" => v)
        }
    end

    def facet_params
      facets.reduce({}) { |memo, (facet)|
        memo.merge("facet_#{facet.key}" => "1000,order:value.title")
      }
    end
  end
end
