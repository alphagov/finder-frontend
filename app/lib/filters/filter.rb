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
  end
end
