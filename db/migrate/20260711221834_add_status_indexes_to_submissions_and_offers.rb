class AddStatusIndexesToSubmissionsAndOffers < ActiveRecord::Migration[8.1]
  def change
    add_index :submissions, :status
    add_index :offers, :status
  end
end
