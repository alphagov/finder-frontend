class ForceCreateEligibilityUuidConstraint < Neo4j::Migrations::Base
  def up
    add_constraint :Eligibility, :uuid, force: true
  end

  def down
    drop_constraint :Eligibility, :uuid
  end
end
