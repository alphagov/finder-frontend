class DrugSafetyUpdate < AbstractDocument

  def summary
    attrs.fetch(:description)
  end

  def self.date_metadata_keys
    %w(
      published_at
    )
  end

  def self.tag_metadata_keys
    %w(
      therapeutic_area
    )
  end

  def self.metadata_name_mappings
    {
      "published_at" => "Published",
    }
  end
end
