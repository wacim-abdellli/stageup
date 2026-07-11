class CreateCompanyProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :company_profiles do |t|
      t.string :name, null: false
      t.string :website
      t.text :description
      t.boolean :verified, null: false, default: false
      t.float :response_rate, null: false, default: 0.0
      t.float :avg_response_time_hours, null: false, default: 0.0
      t.integer :offers_count, null: false, default: 0
      t.datetime :first_offer_posted_at

      t.timestamps
    end
  end
end
