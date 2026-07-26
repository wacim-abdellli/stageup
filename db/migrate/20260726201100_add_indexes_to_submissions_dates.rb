# frozen_string_literal: true

class AddIndexesToSubmissionsDates < ActiveRecord::Migration[8.1]
  def change
    add_index :submissions, :submitted_at
    add_index :submissions, :responded_at
    add_index :submissions, :first_completion_confirmed_at
    add_index :submissions, :submitted_at,
              where: "status IN ('submitted', 'under_review')",
              name: "idx_submissions_submitted_at_pending"
  end
end
