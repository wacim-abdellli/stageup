class CreateSubmissions < ActiveRecord::Migration[8.0]
  def change
    create_table :submissions do |t|
      t.references :student_profile, null: false, foreign_key: true
      t.references :offer, null: false, foreign_key: true
      t.references :mission, null: true, foreign_key: true
      t.string :status, null: false, default: "started"
      t.string :github_link
      t.text :submission_notes
      t.text :feedback
      t.datetime :submitted_at
      t.datetime :responded_at

      t.timestamps
    end

    add_index :submissions, [:student_profile_id, :offer_id], unique: true
  end
end
