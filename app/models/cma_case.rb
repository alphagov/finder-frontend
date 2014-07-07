class CmaCase < AbstractDocument

private

  def date_metadata_mappings
    {
      "opened_date" => "Opened",
      "closed_date" => "Closed",
    }
  end

  def tag_metadata_keys
    [
      "case_type",
      "case_state",
      "market_sector",
      "outcome_type",
    ]
  end

end
