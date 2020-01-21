class StudyRequirement
  include Neo4j::ActiveNode
  has_many :out, :requirements, type: :HAS_REQUIREMENT, model_class: %i(OrRequirementGroup AndRequirementGroup)
  property :at_publicly_funded_school
  property :at_publicly_funded_college
  property :on_unpaid_training_course

  def ineligible?(attributes)
    return false unless attributes.keys.select { |key| requirements_present.include?(key) }.any?

    met_requirements = requirements_present.map { |requirement| attributes[requirement] }
    !met_requirements.all?
  end

private

  def study_requirement_types
    %i(at_publicly_funded_school at_publicly_funded_college on_unpaid_training_course)
  end

  def requirements_present
    study_requirement_types.select { |requirement| read_attribute(requirement).present? }
  end
end
