class DrugSafetyUpdate < AbstractDocument

  def summary
    attrs.fetch(:description, nil)
  end

  def self.tag_metadata_keys
    %w(
      therapeutic_area
    )
  end

  def self.date_metadata_keys
    %w(
      first_published_at
    )
  end

  def self.metadata_name_mappings
    {
      "first_published_at" => "Published",
    }
  end
end
