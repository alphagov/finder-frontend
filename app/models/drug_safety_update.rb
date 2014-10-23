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
      published_date
    )
  end

  def self.metadata_name_mappings
    {
      "published_date" => "Published",
    }
  end
end
