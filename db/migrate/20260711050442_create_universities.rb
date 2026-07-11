class CreateUniversities < ActiveRecord::Migration[8.0]
  def change
    create_table :universities do |t|
      t.string :name, null: false
      t.string :email_domain, null: false
      t.boolean :approved, null: false, default: false

      t.timestamps
    end

    add_index :universities, :name, unique: true
    add_index :universities, :email_domain, unique: true
  end
end
