module LearnToRankFeatureFlag
  def ranker_ab_test_params
    ranker_enabled ? { relevance: "B" } : {}
  end

  def ranker_enabled
    ranker_header = request.headers["Govuk-Use-Search-Reranker"]
    ranker_header.present? && ranker_header == "true"
  end
end
