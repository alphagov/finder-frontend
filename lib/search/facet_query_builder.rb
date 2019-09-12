# Used by Search::QueryBuilder to build the `facet` part of the Rummager
# search query. This will determine the "facets" Rummager returns.
#
# For more on facetting, see the Rummager docs:
#
#   https://github.com/alphagov/rummager/blob/master/docs/search-api.md
module Search
  class FacetQueryBuilder
    def initialize(facets:)
      @facets = facets
    end

    def call
      dynamic_facets.reduce({}) { |query, facet|
        # TODO title will only work for Orgs, this key will need changed for
        # other dynamic facets
        #
        # "1500,order:value.title" is specifying that we want 1500 results back
        # which are ordered by the title attribute of each value (option)
        # that is returned
        key = (facet["filter_key"] || facet["key"])
        query.merge(key => "1500,order:value.title")
      }
    end

  private

    attr_reader :facets

    def dynamic_facets
      facets_that_could_be_dynamic.select { |f| f["allowed_values"].blank? }
    end

    def facets_that_could_be_dynamic
      filterable_facets.select { |f| %w(text hidden_clearable).include? f["type"] }
    end

    def filterable_facets
      facets.select { |f| f["filterable"] }
    end
  end
end
