class PopulateAndCategorizeAllSkills < ActiveRecord::Migration[8.1]
  def up
    # Loads the full 300+ skills taxonomy across 15 domains idempotently
    load Rails.root.join("db", "seeds_skills.rb")
  end

  def down
    # Keep skills intact upon rollback
  end
end
