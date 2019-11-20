class CreateScores < ActiveRecord::Migration[6.0]
  def change
    create_table :scores do |t|
      t.string :link
      t.string :judgement
      t.integer :link_position

      t.timestamps
    end
  end
end
