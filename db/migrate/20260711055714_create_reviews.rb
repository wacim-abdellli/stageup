class CreateReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :reviews do |t|
      t.references :submission, null: false, foreign_key: true
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.references :receiver, null: false, foreign_key: { to_table: :users }
      t.integer :rating, null: false
      t.text :comment, null: false

      t.timestamps
    end

    add_index :reviews, [:submission_id, :author_id], unique: true
  end
end
