class CreateStudentProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :student_profiles do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :phone
      t.references :university, null: true, foreign_key: true
      t.string :major
      t.integer :graduation_year
      t.text :bio
      t.float :commitment_score, null: false, default: 100.0

      t.timestamps
    end
  end
end
