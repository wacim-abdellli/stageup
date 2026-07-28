class AddCategoryToSkills < ActiveRecord::Migration[8.1]
  def change
    add_column :skills, :category, :string
  end
end
