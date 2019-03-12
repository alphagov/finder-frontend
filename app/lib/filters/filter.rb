module Filters
  class Filter
    def initialize(facet, params)
      @facet = facet
      @params = params
    end

    def key
      facet['filter_key'] || facet['key']
    end

    def active?
      value.present?
    end

    def value
      raise NotImplementedError
    end

  private

    attr_reader :facet, :params

    def parsed_value
      return [] if params.blank?

      if multi_value?
        option_lookup.select { |key, _| params.include? key }.values.flatten
      else
        Array(params)
      end
    end

    def multi_value?
      facet.has_key?('option_lookup')
    end

    def option_lookup
      @option_lookup ||= facet['option_lookup']
    end
  end
end
