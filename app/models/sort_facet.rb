# SortFacet is a "virtual" facet, in that it is only used for the new all content finder UI, where
# sorting forms part of the overall filtering UI instead of being separate
class SortFacet
  KEY = "order".freeze

  def name
    "Sort by"
  end
  alias_method :ga4_section, :name

  def key
    KEY
  end

  def to_partial_path
    self.class.name.underscore
  end

  def user_visible?
    true
  end

  # The methods below are the minimum required for this virtual facet to take the place of a real
  # `Facet`

  def has_filters?
    false
  end

  def filterable?
    true
  end

  def hide_facet_tag?
    false
  end

  def metadata?
    false
  end

private

  attr_reader :sort_presenter
end
