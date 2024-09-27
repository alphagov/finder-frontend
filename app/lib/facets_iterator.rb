class FacetsIterator
  include Enumerable
  delegate :each, to: :@facets

  def initialize(facets)
    @facets = facets
    @user_visible_facets = @facets.select(&:user_visible?)
  end

  def each_with_visible_index_and_count
    @facets.each do |facet|
      yield facet, @user_visible_facets.index(facet), @user_visible_facets.count
    end
  end
end
