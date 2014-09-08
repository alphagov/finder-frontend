class MedicalSafetyAlert < AbstractDocument
  def self.date_metadata_keys
    %w(
      published_at
    )
  end

  def self.tag_metadata_keys
    %w(
      alert_type
      medical_specialism
    )
  end

  def self.metadata_name_mappings
    {
      "published_at" => "Published",
    }
  end
end
