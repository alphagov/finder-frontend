module BrexitQuestionsAbTestable
  CUSTOM_DIMENSION = 43
  TEST_NAME = "TransitionChecker1".freeze

  def brexit_question_variant
    @brexit_question_variant ||= begin
      ab_test = GovukAbTesting::AbTest.new(
        TEST_NAME,
        dimension: CUSTOM_DIMENSION,
        allowed_variants: %w[A B Z],
        control_variant: "Z",
      )
      ab_test.requested_variant(request.headers)
    end
  end

  def show_brexit_question_variant?
    brexit_question_variant.variant?("B")
  end
end
