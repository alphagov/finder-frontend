class InternationalDevelopmentFund < AbstractDocument
  def summary
    truncated_summary_or_nil
  end

  def self.tag_metadata_keys
    %w(
      fund_state
      location
    )
  end
end
