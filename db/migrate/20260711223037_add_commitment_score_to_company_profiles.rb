class AddCommitmentScoreToCompanyProfiles < ActiveRecord::Migration[8.1]
  def change
    add_column :company_profiles, :commitment_score, :float, default: 100.0, null: false
  end
end
