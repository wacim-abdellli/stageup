class CreateSkillsAndJoinTables < ActiveRecord::Migration[7.1]
  def change
    create_table :skills do |t|
      t.string :name, null: false
      t.timestamps
    end
    add_index :skills, :name, unique: true

    create_table :skills_student_profiles, id: false do |t|
      t.references :student_profile, null: false, foreign_key: true
      t.references :skill, null: false, foreign_key: true
    end
    add_index :skills_student_profiles, [ :student_profile_id, :skill_id ], unique: true

    create_table :offers_skills, id: false do |t|
      t.references :offer, null: false, foreign_key: true
      t.references :skill, null: false, foreign_key: true
    end
    add_index :offers_skills, [ :offer_id, :skill_id ], unique: true
  end
end
