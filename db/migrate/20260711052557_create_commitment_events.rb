class CreateCommitmentEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :commitment_events do |t|
      t.references :profileable, polymorphic: true, null: false
      t.string :event_type, null: false
      t.float :score_delta, null: false, default: 0.0
      t.text :description, null: false

      t.timestamps
    end
  end
end
