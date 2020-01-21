class ForceCreateAndRequirementGroupUuidConstraint < Neo4j::Migrations::Base
  def up
    add_constraint :AndRequirementGroup, :uuid, force: true
  end

  def down
    drop_constraint :AndRequirementGroup, :uuid
  end
end
