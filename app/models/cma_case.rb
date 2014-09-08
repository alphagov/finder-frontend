class CmaCase < AbstractDocument
  def self.date_metadata_keys
    %w(
      opened_date
      closed_date
    )
  end

  def self.tag_metadata_keys
    %w(
      case_type
      case_state
      market_sector
      outcome_type
    )
  end

  def self.metadata_name_mappings
    {
      "opened_date" => "Opened",
      "closed_date" => "Closed",
    }
  end
end
