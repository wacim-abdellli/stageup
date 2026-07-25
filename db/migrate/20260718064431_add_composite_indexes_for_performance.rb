class AddCompositeIndexesForPerformance < ActiveRecord::Migration[7.1]
  def change
    add_index :offers, [ :company_profile_id, :status ], name: "index_offers_on_company_profile_id_and_status"
    add_index :notifications, [ :recipient_id, :recipient_type, :created_at ], name: "idx_on_recipient_id_recipient_type_created_at"
  end
end
