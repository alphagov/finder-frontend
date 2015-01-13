class Contact < AbstractDocument
  def self.tag_metadata_keys
    %w(
      contact_group
    )
  end

  def self.metadata_name_mappings
    {
      "contact_group" => "Topic",
    }
  end
end
