module HideKeywordFacetTagsABTestable
  CUSTOM_DIMENSION = 43

  def self.included(base)
    base.helper_method(
      :hide_keyword_facet_tags_variant,
      :hide_keyword_facet_tags_ab_test,
      :in_hide_keyword_facet_tags_ab_test_scope?,
    )
    base.after_action :set_hide_keyword_facet_tags_response_header
  end

  def hide_keyword_facet_tags_ab_test
    return {} if hide_keyword_facet_tags_variant.variant?("A")

    { hide_keyword_facet_tags: hide_keyword_facet_tags_variant.variant_name }
  end

  def hide_keyword_facet_tags_test
    @hide_keyword_facet_tags_test ||= GovukAbTesting::AbTest.new(
      "HideKeywordFacetTagsABTest",
      dimension: CUSTOM_DIMENSION,
      allowed_variants: %w(A B),
      control_variant: "A",
    )
  end

  def hide_keyword_facet_tags_variant
    @hide_keyword_facet_tags_variant ||= hide_keyword_facet_tags_test.requested_variant(request.headers)
  end

  def set_hide_keyword_facet_tags_response_header
    hide_keyword_facet_tags_variant.configure_response(response) if in_hide_keyword_facet_tags_ab_test_scope?
  end

  def in_hide_keyword_facet_tags_ab_test_scope?
    content_item.is_finder?
  end
end
