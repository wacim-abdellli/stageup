class AddAutoVerificationToSubmissions < ActiveRecord::Migration[7.1]
  def change
    add_column :submissions, :auto_verification_status, :string, default: "pending", null: false
    add_column :submissions, :auto_verification_log, :text
  end
end
