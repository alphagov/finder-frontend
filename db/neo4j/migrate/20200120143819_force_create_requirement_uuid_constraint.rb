class ForceCreateRequirementUuidConstraint < Neo4j::Migrations::Base
  def up
    add_constraint :Requirement, :uuid, force: true
  end

  def down
    drop_constraint :Requirement, :uuid
  end
end
