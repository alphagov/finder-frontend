class FacetsIterator
  include Enumerable

  def initialize(facets)
    @facets = facets
    @user_visible_facets = @facets.select(&:user_visible?)
  end

  def user_visible_count
    @user_visible_facets.count
  end

  def each
    @facets.each do |facet|
      yield FacetPresenter.new(facet, @user_visible_facets.index(facet), user_visible_count)
    end
  end
end
