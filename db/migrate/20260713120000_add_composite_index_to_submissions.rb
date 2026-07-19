class AddCompositeIndexToSubmissions < ActiveRecord::Migration[8.1]
  def change
    add_index :submissions, [ :student_profile_id, :status ],
              name: "index_submissions_on_student_profile_id_and_status"
  end
end
