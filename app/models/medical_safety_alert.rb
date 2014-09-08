class MedicalSafetyAlert < AbstractDocument
  def self.tag_metadata_keys
    %w(
      alert_type
      medical_specialism
    )
  end
end
