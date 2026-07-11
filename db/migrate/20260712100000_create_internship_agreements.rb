class CreateInternshipAgreements < ActiveRecord::Migration[7.1]
  def change
    create_table :internship_agreements do |t|
      t.bigint :submission_id, null: false
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.datetime :student_signed_at
      t.datetime :company_signed_at
      t.datetime :university_signed_at
      t.string :status, null: false, default: "pending_signatures"

      t.timestamps
    end

    add_index :internship_agreements, :submission_id, unique: true
    add_foreign_key :internship_agreements, :submissions
  end
end
