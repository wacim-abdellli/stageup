# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

# Auto-prepare SQLite database schema for serverless environments (Vercel)
# This runs migrations if the schema_migrations table doesn't exist yet.
if Rails.env.production? && !ENV["DATABASE_URL"].present?
  begin
    conn = ActiveRecord::Base.connection
    unless conn.table_exists?("schema_migrations")
      Rails.logger.info "[Vercel] Running db:schema:load for fresh SQLite database..."
      load(Rails.root.join("db", "schema.rb"))
    end
  rescue => e
    Rails.logger.warn "[Vercel] DB setup warning: #{e.message}"
  end
end

run Rails.application
Rails.application.load_server
