class ForceCreateOrRequirementGroupUuidConstraint < Neo4j::Migrations::Base
  def up
    add_constraint :OrRequirementGroup, :uuid, force: true
  end

  def down
    drop_constraint :OrRequirementGroup, :uuid
  end
end
