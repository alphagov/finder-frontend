module DocumentParser
  def self.parse(document_hash)
    CmaCase.new(document_hash.with_indifferent_access)
  end
end
