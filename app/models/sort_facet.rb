# SortFacet is a "virtual" facet, in that it is only used for the new all content finder UI, where
# sorting forms part of the overall filtering UI instead of being separate
class SortFacet
  KEY = "order".freeze
  DEFAULT_SORT_OPTIONS = %w[relevance most-viewed].freeze

  def initialize(content_item, filter_params)
    @content_item = content_item
    @filter_params = filter_params
  end

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

  def has_filters?
    sort_options.keys.include?(selected_sort_option) &&
      !DEFAULT_SORT_OPTIONS.include?(selected_sort_option)
  end

  def applied_filters
    return [] unless has_filters?

    [{
      name:,
      label: sort_options[selected_sort_option],
      query_params: { KEY => selected_sort_option },
      visually_hidden_prefix: "Remove",
    }]
  end

  # The methods below are the minimum required for this virtual facet to take the place of a real
  # `Facet`

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

  attr_reader :content_item, :filter_params

  def sort_options
    # Finder Frontend's sort handling is somewhat bizarre - it doesn't use the sort option keys from
    # the content item, but rather the sort options' names parameterized.
    content_item.sort_options.to_h { [_1["name"].parameterize, _1["name"]] }
  end

  def selected_sort_option
    filter_params[KEY]
  end
end
