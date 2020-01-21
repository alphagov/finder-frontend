class ForceCreateAgeRequirementUuidConstraint < Neo4j::Migrations::Base
  def up
    add_constraint :AgeRequirement, :uuid, force: true
  end

  def down
    drop_constraint :AgeRequirement, :uuid
  end
end
