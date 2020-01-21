class Eligibility
  include Neo4j::ActiveNode
  has_many :in, :cids, type: :HAS_ELIGIBILITY, model_class: :Cid
  has_one :out, :requirement, type: :HAS_REQUIREMENT, model_class: %i(OrRequirementGroup AndRequirementGroup)

  def ineligible?(attributes)
    requirement.ineligible?(attributes)
  end
end
