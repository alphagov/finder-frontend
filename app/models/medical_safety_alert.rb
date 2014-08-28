class MedicalSafetyAlert < AbstractDocument
private
  def date_metadata_keys
    %w(
      published_at
    )
  end

  def tag_metadata_keys
    %w(
      alert_type
      medical_specialism
    )
  end

  def metadata_name_mappings
    {
      "published_at" => "Published",
    }
  end
end
