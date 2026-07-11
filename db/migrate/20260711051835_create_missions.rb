class CreateMissions < ActiveRecord::Migration[8.0]
  def change
    create_table :missions do |t|
      t.references :offer, null: false, foreign_key: true
      t.string :title, null: false
      t.text :instructions, null: false
      t.integer :estimated_duration_minutes, null: false

      t.timestamps
    end
  end
end
