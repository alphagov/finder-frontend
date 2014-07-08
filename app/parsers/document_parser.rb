module DocumentParser
  def self.parse(document_hash)
    document_hash = document_hash.with_indifferent_access

    case document_hash.fetch(:document_type)
    when "aaib_report"
      AaibReport.new(document_hash)
    when "cma_case"
      CmaCase.new(document_hash)
    end
  end
end
