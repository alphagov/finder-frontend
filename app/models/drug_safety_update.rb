class DrugSafetyUpdate < AbstractDocument

  def summary
    attrs.fetch(:description, nil)
  end

  def self.tag_metadata_keys
    %w(
      therapeutic_area
    )
  end
end
