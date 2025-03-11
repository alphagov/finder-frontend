module Filters
  class NestedFilter < Filter
    def initialize(facet, params)
      @main_facet_key = params["main_facet_key"]
      @sub_facet_key = params["sub_facet_key"]
      @main_facet_value = params[@main_facet_key]
      @sub_facet_value = params[@sub_facet_key]

      super
    end

    def query_hash
      return {} unless @main_facet_value && @sub_facet_value

      { @main_facet_key => [@main_facet_value], @sub_facet_key => [@sub_facet_value] }
    end

  private

    def value
      @value ||= begin
        return nil unless params

        [@main_facet_value, @sub_facet_value]
      end
    end
  end
end
