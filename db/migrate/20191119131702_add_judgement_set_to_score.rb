class AddJudgementSetToScore < ActiveRecord::Migration[6.0]
  def change
    add_reference :scores, :judgement_set, null: false, foreign_key: true
  end
end
