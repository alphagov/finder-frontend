class AaibReport < AbstractDocument

  def summary
    truncated_summary_or_nil
  end

private
  def self.date_metadata_keys
    %w(
      date_of_occurrence
    )
  end

  def self.tag_metadata_keys
    %w(
      aircraft_category
      report_type
    )
  end

  def self.metadata_name_mappings
    {
      "date_of_occurrence" => "Occurred",
    }
  end
end
