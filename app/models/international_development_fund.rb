class InternationalDevelopmentFund < AbstractDocument
private
  def tag_metadata_keys
    %w(
      application_state
      location
    )
  end
end
