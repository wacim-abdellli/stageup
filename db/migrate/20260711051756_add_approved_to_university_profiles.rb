class AddApprovedToUniversityProfiles < ActiveRecord::Migration[8.0]
  def change
    add_column :university_profiles, :approved, :boolean, null: false, default: false
  end
end
