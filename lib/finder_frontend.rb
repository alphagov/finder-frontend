require 'gds_api/rummager'

module FinderFrontend
  def self.get_documents(finder, params)
    query = SearchQueryBuilder.new(
      base_filter: finder.filter.to_h,
      metadata_fields: finder.facet_keys,
      default_order: finder.default_order,
      params: params,
    ).call

    rummager_api.unified_search(query).to_hash
  end

  def self.rummager_api
    GdsApi::Rummager.new(Plek.find("search"))
  end

  class SearchQueryBuilder
    def initialize(base_filter:, metadata_fields:, default_order:, params:)
      @base_filter = base_filter
      @metadata_fields = metadata_fields
      @default_order = default_order || "-public_timestamp"
      @params = params
    end

    def call
      default_params.merge(massaged_params)
    end

  private

    attr_reader :base_filter, :metadata_fields, :default_order, :params

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
  end
end
