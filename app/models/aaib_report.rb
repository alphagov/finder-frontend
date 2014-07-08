class AaibReport < AbstractDocument
private
  def date_metadata_keys
    %w(
      date_of_occurrence
    )
  end

  def tag_metadata_keys
    %w(
      aircraft_category
      report_type
    )
  end

  def metadata_name_mappings
    {
      "date_of_occurrence" => "Occurred",
    }
  end
end
