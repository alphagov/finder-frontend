class CreateJudgementSets < ActiveRecord::Migration[6.0]
  def change
    create_table :judgement_sets do |t|
      t.string :query
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
