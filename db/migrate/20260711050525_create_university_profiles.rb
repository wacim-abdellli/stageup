class CreateUniversityProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :university_profiles do |t|
      t.references :university, null: false, foreign_key: true
      t.string :admin_name, null: false
      t.string :department, null: false

      t.timestamps
    end
  end
end
