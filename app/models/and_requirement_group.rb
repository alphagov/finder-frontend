class AndRequirementGroup
  include Neo4j::ActiveNode

  has_many :in, :eligibilities, type: :HAS_REQUIREMENT, model_class: :Eligibility
  has_many :out, :requirements, type: :HAS_REQUIREMENT, model_class: false

  def ineligible?(attributes)
    requirements.map { |requirement| requirement.ineligible?(attributes) }.any?
  end
end
