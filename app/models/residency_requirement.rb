class ResidencyRequirement
  include Neo4j::ActiveNode
  has_many :out, :requirements, type: :HAS_REQUIREMENT, model_class: %i(OrRequirementGroup AndRequirementGroup)
  property :meet_residency_requirement

  def ineligible?(attributes)
    return false unless attributes.keys.include?(:meet_residency_requirement)

    !attributes[:meet_residency_requirement]
  end
end
