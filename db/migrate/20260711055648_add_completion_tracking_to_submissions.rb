class AddCompletionTrackingToSubmissions < ActiveRecord::Migration[8.1]
  def change
    add_column :submissions, :student_confirmed_completed, :boolean, default: false, null: false
    add_column :submissions, :company_confirmed_completed, :boolean, default: false, null: false
    add_column :submissions, :first_completion_confirmed_at, :datetime
  end
end
