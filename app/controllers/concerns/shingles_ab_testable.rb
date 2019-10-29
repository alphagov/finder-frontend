module ShinglesABTestable
  CUSTOM_DIMENSION = 42

  def self.included(base)
    base.helper_method(
      :shingles_variant,
      :shingles_ab_test,
      :in_shingles_ab_test_scope?,
    )
    base.after_action :set_shingles_response_header
  end

  def shingles_ab_test
    return {} if shingles_variant.variant?("A")

    { shingles: shingles_variant.variant_name }
  end

  def shingles_test
    @shingles_test ||= GovukAbTesting::AbTest.new(
      "ShinglesABTest",
      dimension: CUSTOM_DIMENSION,
      allowed_variants: %w(A B),
      control_variant: "A",
    )
  end

  def shingles_variant
    @shingles_variant ||= shingles_test.requested_variant(request.headers)
  end

  def set_shingles_response_header
    shingles_variant.configure_response(response) if in_shingles_ab_test_scope?
  end

  def in_shingles_ab_test_scope?
    content_item.is_finder?
  end
end
