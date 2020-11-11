module BrexitResultsAbTestable
  CUSTOM_DIMENSION = 44
  TEST_NAME = "TransitionUrgency5".freeze

  def brexit_urgency_variant
    @brexit_urgency_variant ||= begin
      ab_test = GovukAbTesting::AbTest.new(
        TEST_NAME,
        dimension: CUSTOM_DIMENSION,
        allowed_variants: %w[A B Z],
        control_variant: "Z",
      )
      ab_test.requested_variant(request.headers)
    end
  end

  def show_urgency_variant?
    brexit_urgency_variant.variant?("B")
  end
end
