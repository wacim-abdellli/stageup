# frozen_string_literal: true

class AddCheckConstraintForProfileableTypeOnUsers < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
      ALTER TABLE users
      ADD CONSTRAINT check_profileable_type
      CHECK (profileable_type IN ('StudentProfile', 'CompanyProfile', 'UniversityProfile'));
    SQL
  end

  def down
    execute "ALTER TABLE users DROP CONSTRAINT IF EXISTS check_profileable_type;"
  end
end
