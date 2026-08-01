class AddTrgmAndEventsIndexes < ActiveRecord::Migration[8.1]
  def change
    enable_extension "pg_trgm" unless extension_enabled?("pg_trgm")

    unless index_exists?(:offers, :title, name: "idx_offers_title_trgm")
      add_index :offers, :title, using: :gin, opclass: :gin_trgm_ops, name: "idx_offers_title_trgm"
    end

    unless index_exists?(:offers, :description, name: "idx_offers_description_trgm")
      add_index :offers, :description, using: :gin, opclass: :gin_trgm_ops, name: "idx_offers_description_trgm"
    end

    unless index_exists?(:company_profiles, :name, name: "idx_company_profiles_name_trgm")
      add_index :company_profiles, :name, using: :gin, opclass: :gin_trgm_ops, name: "idx_company_profiles_name_trgm"
    end

    unless index_exists?(:commitment_events, [:profileable_type, :profileable_id, :event_type], name: "idx_commitment_events_profile_event_type")
      add_index :commitment_events, [:profileable_type, :profileable_id, :event_type], name: "idx_commitment_events_profile_event_type"
    end
  end
end
