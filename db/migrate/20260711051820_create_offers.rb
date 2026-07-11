class CreateOffers < ActiveRecord::Migration[8.0]
  def change
    create_table :offers do |t|
      t.references :company_profile, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description, null: false
      t.string :stage_type, null: false
      t.integer :spots, null: false, default: 1
      t.string :location, null: false
      t.string :work_mode, null: false, default: "onsite"
      t.string :status, null: false, default: "active"
      t.datetime :deadline

      t.timestamps
    end
  end
end
