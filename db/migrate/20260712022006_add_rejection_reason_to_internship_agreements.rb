class AddRejectionReasonToInternshipAgreements < ActiveRecord::Migration[7.1]
  def change
    add_column :internship_agreements, :rejection_reason, :text
  end
end
