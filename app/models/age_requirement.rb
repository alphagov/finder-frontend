class AgeRequirement
  include Neo4j::ActiveNode
  has_many :out, :requirements, type: :HAS_REQUIREMENT, model_class: %i(OrRequirementGroup AndRequirementGroup)
  property :min_age
  property :max_age

  def ineligible?(attributes)
    return false if attributes[:age].blank?

    met_requirements = requirements_present.map { |requirement| send(requirement, attributes) }
    !met_requirements.all?
  end

private

  def requirements_present
    criteria = { min_age: "meets_min_age_requirement?", max_age: "meets_max_age_requirement?" }
    %i(min_age max_age).each_with_object([]) do |requirement, requirements|
      if read_attribute(requirement).present?
        requirements << criteria[requirement]
      end
    end
  end

  def meets_min_age_requirement?(attributes)
    attributes[:age] >= min_age
  end

  def meets_max_age_requirement?(attributes)
    attributes[:age] <= max_age
  end
end
