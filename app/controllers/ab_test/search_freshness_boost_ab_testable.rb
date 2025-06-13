module AbTest::SearchFreshnessBoostAbTestable
  def search_freshness_boost_ab_test
    GovukAbTesting::AbTest.new(
      "SearchFreshnessBoost",
      allowed_variants: [
        "A", # default serving config (legacy freshness boost)
        "B", # variant serving config (new control-based freshness boost)
        "Z", # default serving config (legacy freshness boost)
      ],
      control_variant: "Z",
    )
  end

  def set_search_freshness_boost_ab_test_requested_variant
    @requested_variant = search_freshness_boost_ab_test.requested_variant(request.headers)
    @requested_variant.configure_response(response)
  end

  def v2_serving_config
    return "variant_search" if @requested_variant&.variant?("B")

    # Let Search API v2 decide which "default" serving config to use.
    nil
  end
end
