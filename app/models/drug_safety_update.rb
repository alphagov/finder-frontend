class DrugSafetyUpdate < AbstractDocument
private
  def date_metadata_keys
    %w(
      published_at
    )
  end

  def tag_metadata_keys
    %w(
      therapeutic_area
    )
  end

  def metadata_name_mappings
    {
      "published_at" => "Published",
    }
  end
end
