# frozen_string_literal: true

class AddCachedAverageRatingToProfiles < ActiveRecord::Migration[8.1]
  def change
    add_column :company_profiles, :cached_average_rating, :float, default: nil
    add_column :student_profiles, :cached_average_rating, :float, default: nil
  end
end