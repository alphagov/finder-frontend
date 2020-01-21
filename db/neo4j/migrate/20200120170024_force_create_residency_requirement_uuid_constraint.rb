class ForceCreateResidencyRequirementUuidConstraint < Neo4j::Migrations::Base
  def up
    add_constraint :ResidencyRequirement, :uuid, force: true
  end

  def down
    drop_constraint :ResidencyRequirement, :uuid
  end
end
