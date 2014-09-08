require 'gds_api/finder_api'
require 'gds_api/rummager'

module FinderFrontend
  def self.get_documents(slug, document_type, params)
    FindDocuments.new(get_schema(slug), document_type, params).call
  end

  def self.get_schema(finder_slug)
    @schemae ||= {}
    @schemae[finder_slug] ||= finder_api.get_schema(finder_slug)
  end

  def self.finder_api
    @finder_api ||= GdsApi::FinderApi.new(Plek.new.find('finder-api'))
  end

  class FindDocuments
    def initialize(schema, document_type, params)
      @schema = schema
      # TODO Get `document_type` from `schema`
      @document_type = document_type
      @params = params
    end

    def call
      rummager_api.unified_search(default_params.merge(massaged_params))
      .to_hash
      .fetch("results")
      .map { |doc|
        doc.merge(
          "slug" => doc.fetch("link"),
        )
      }
    end

  private

    attr_reader :schema, :document_type, :params

    def default_params
      {
        "count"  => "1000",
        "fields" => return_fields.join(","),
      }
    end

    def return_fields
      %w(title link).concat(metadata_fields)
    end

    def presenter_class
      {
        "aaib_report" => AaibReport,
        "cma_case" => CmaCase,
        "drug_safety_update" => DrugSafetyUpdate,
        "international_development_fund" => InternationalDevelopmentFund,
        "medical_safety_alert" => MedicalSafetyAlert,
      }.fetch(document_type) { |type| raise "Unknown document type #{type}" }
    end

    def metadata_fields
      presenter_class.metadata_keys
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
