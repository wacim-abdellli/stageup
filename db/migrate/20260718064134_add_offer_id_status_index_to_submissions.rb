# frozen_string_literal: true

class AddOfferIdStatusIndexToSubmissions < ActiveRecord::Migration[8.1]
  def change
    add_index :submissions, [:offer_id, :status],
              name: "index_submissions_on_offer_id_and_status"
  end
end