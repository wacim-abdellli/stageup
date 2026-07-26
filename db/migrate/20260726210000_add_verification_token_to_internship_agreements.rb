# frozen_string_literal: true

class AddVerificationTokenToInternshipAgreements < ActiveRecord::Migration[8.1]
  def change
    add_column :internship_agreements, :verification_token, :string
    add_index :internship_agreements, :verification_token, unique: true

    reversible do |dir|
      dir.up do
        InternshipAgreement.where(verification_token: nil).find_each do |a|
          a.update_column(:verification_token, SecureRandom.urlsafe_base64(16))
        end
      end
    end
  end
end
