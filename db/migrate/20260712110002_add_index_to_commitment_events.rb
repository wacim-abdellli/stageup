class AddIndexToCommitmentEvents < ActiveRecord::Migration[8.1]
  def change
    add_index :commitment_events, [ :profileable_type, :profileable_id, :created_at ],
              name: "index_commitment_events_on_profile_and_created_at"
  end
end
