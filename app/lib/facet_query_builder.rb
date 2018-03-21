# Used by the SearchQueryBuilder to build the `facet` part of the Rummager
# search query. This will determine the "facets" Rummager returns.
#
# For more on facetting, see the Rummager docs:
#
#   https://github.com/alphagov/rummager/blob/master/docs/search-api.md
class FacetQueryBuilder
  def initialize(facets:)
    @facets = facets
  end

  def call
    dynamic_facets.reduce({}) { |query, facet|
      # TODO title will only work for Orgs, this key will need changed for
      # other dynamic facets
      #
      # "1000,order:value.title" is specifying that we want 1000 results back
      # which are ordered by the title attribute of each value (option)
      # that is returned
      key = (facet['filter_key'] || facet['key'])
      query.merge(key => "1000,order:value.title")
    }
  end

private

  attr_reader :facets

  def dynamic_facets
    text_facets.select { |f| f['allowed_values'].blank? }
  end

  def text_facets
    filterable_facets.select { |f| f['type'] == "text" }
  end

  def filterable_facets
    facets.select { |f| f['filterable'] }
  end
end
