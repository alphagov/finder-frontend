require 'gds_api/rummager'

module FinderFrontend
  def self.get_documents(finder, params)
    FindDocuments.new(finder, params).call
  end

  class FindDocuments
    def initialize(finder, params)
      # TODO Get `document_type` from `schema`
      @finder = finder
      @document_type = finder.document_type
      @params = params
    end

    def call
      rummager_api.unified_search(default_params.merge(massaged_params))
        .to_hash
    end

  private

    attr_reader :document_type, :params, :finder

    def default_params
      {
        "count"  => "1000",
        "fields" => return_fields.join(","),
      }
    end

    def base_return_fields
      %w(
        title
        link
        description
      )
    end

    def return_fields
      base_return_fields.concat(metadata_fields)
    end

    def metadata_fields
      finder.facets.to_a.map(&:key)
    end

    def massaged_params
      ParamsMassager.new(params, document_type).to_h
    end

    def rummager_api
      @rummager_api ||= GdsApi::Rummager.new(Plek.new.find('search'))
    end
  end

  class ParamsMassager
    def initialize(params, document_type)
      @params = params
      @document_type = document_type
    end

    def to_h
      keyword_param
        .merge(filter_params)
        .merge(document_type_param)
        .merge(order_param)
    end

  private
    attr_reader :params, :document_type

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
        {"order" => "-last_update"}
      end
    end

    def filter_params
      params
        .except("keywords")
        .reduce({}) { |memo, (k,v)|
          memo.merge("filter_#{k}" => v)
        }
    end

    def document_type_param
      {
        "filter_document_type" => document_type,
      }
    end
  end
end
