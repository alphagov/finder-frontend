module PartsInResultsAbTestable
  CUSTOM_DIMENSION = 42
  ALLOWED_VARIANTS = %w(unchanged showparts).freeze

  def self.included(base)
    base.helper_method(:parts_in_results_variant)
    base.after_action :set_parts_in_results_response_header
  end

  def show_parts_in_results
    parts_in_results_variant.variant?("showparts")
  end

  def parts_in_results_test
    @parts_in_results_test ||= GovukAbTesting::AbTest.new(
      "ShowPartsInResultsABTest",
      dimension: CUSTOM_DIMENSION,
      allowed_variants: ALLOWED_VARIANTS,
      control_variant: "unchanged",
    )
  end

  def parts_in_results_variant
    @parts_in_results_variant ||= parts_in_results_test.requested_variant(request.headers)
  end

  def set_parts_in_results_response_header
    parts_in_results_variant.configure_response(response)
  end
end
