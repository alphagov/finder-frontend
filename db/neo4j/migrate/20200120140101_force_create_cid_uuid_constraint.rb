class ForceCreateCidUuidConstraint < Neo4j::Migrations::Base
  def up
    add_constraint :Cid, :uuid, force: true
  end

  def down
    drop_constraint :Cid, :uuid
  end
end
