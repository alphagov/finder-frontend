class InternationalDevelopmentFund < AbstractDocument
  def self.tag_metadata_keys
    %w(
      fund_state
      location
    )
  end
end
