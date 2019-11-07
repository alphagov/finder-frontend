module FinderPopularityAbTestable
  CUSTOM_DIMENSION = 43

  def self.included(base)
    base.helper_method(
      :popularity_variant,
      :popularity_ab_test,
      :in_popularity_ab_test_scope?,
    )
    base.after_action :set_popularity_response_header
  end

  def popularity_ab_test
    if popularity_variant.variant?("A")
      {}
    else
      { popularity: popularity_variant.variant_name }
    end
  end

  def popularity_test
    @popularity_test ||= GovukAbTesting::AbTest.new(
      "FinderPopularityABTest",
      dimension: CUSTOM_DIMENSION,
      allowed_variants: %w(A C),
      control_variant: "A",
    )
  end

  def popularity_variant
    @popularity_variant ||= popularity_test.requested_variant(request.headers)
  end

  def set_popularity_response_header
    popularity_variant.configure_response(response) if in_popularity_ab_test_scope?
  end

  def in_popularity_ab_test_scope?
    content_item.is_finder?
  end
end
