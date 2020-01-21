class ForceCreateStudyRequirementUuidConstraint < Neo4j::Migrations::Base
  def up
    add_constraint :StudyRequirement, :uuid, force: true
  end

  def down
    drop_constraint :StudyRequirement, :uuid
  end
end
