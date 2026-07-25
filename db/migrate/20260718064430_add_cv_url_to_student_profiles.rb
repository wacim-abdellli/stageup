class AddCvUrlToStudentProfiles < ActiveRecord::Migration[7.1]
  def change
    add_column :student_profiles, :cv_url, :string
  end
end
