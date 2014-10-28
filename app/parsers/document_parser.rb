module DocumentParser
  def self.parse(document_hash)
    document_hash = document_hash.with_indifferent_access

    case document_hash.fetch(:document_type)
    when "aaib_report"
      AaibReport.new(document_hash)
    when "cma_case"
      CmaCase.new(document_hash)
    when "international_development_fund"
      InternationalDevelopmentFund.new(document_hash)
    when "drug_safety_update"
      DrugSafetyUpdate.new(document_hash)
    when "maib_report"
      MaibReport.new(document_hash)
    when "medical_safety_alert"
      MedicalSafetyAlert.new(document_hash)
    end
  end
end
