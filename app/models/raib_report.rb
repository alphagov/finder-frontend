class RaibReport < AbstractDocument
private
  def self.date_metadata_keys
    %w(
      date_of_occurrence
    )
  end

  def self.tag_metadata_keys
    %w(
      railway_type
      report_type
    )
  end

  def self.metadata_name_mappings
    {
      "date_of_occurrence" => "Occurred",
    }
  end
end
