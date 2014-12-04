class MedicalSafetyAlert < AbstractDocument
  def summary
    truncated_summary_or_nil
  end

  def self.tag_metadata_keys
    %w(
      alert_type
      medical_specialism
    )
  end

  def self.date_metadata_keys
    %w(
      issued_date
    )
  end

  def self.metadata_name_mappings
    {
      "issued_date" => "Issued",
    }
  end
end
