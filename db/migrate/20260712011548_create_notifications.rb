class CreateNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :notifications do |t|
      t.references :recipient, null: false, polymorphic: true
      t.references :notifiable, null: false, polymorphic: true
      t.string :action, null: false
      t.string :message, null: false
      t.boolean :read, default: false, null: false

      t.timestamps
    end

    add_index :notifications, [:recipient_id, :recipient_type, :read]
    add_index :notifications, :created_at
  end
end
