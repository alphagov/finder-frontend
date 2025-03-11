module Filters
  class NestedFilter < Filter
    def initialize(facet, params)
      super

      return if params.blank?

      @main_facet_key = params["main_facet_key"]
      @sub_facet_key = params["sub_facet_key"]
      @main_facet_value = params[@main_facet_key]
      @sub_facet_value = params[@sub_facet_key]
    end

    def query_hash
      result = {}
      result.merge!(@main_facet_key => [@main_facet_value]) if @main_facet_value
      result.merge!(@sub_facet_key => [@sub_facet_value]) if @sub_facet_value

      result
    end

  private

    def value
      @value ||= begin
        return nil unless @main_facet_value || @sub_facet_value

        [@main_facet_value, @sub_facet_value].compact
      end
    end
  end
end
