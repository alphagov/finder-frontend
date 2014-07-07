class AaibReport < AbstractDocument

private

  def date_metadata_mappings
    {
      "date_of_occurrence" => "Occurred"
    }
  end

  def tag_metadata_keys
    [
      "aircraft_category",
      "report_type",
    ]
  end

end
