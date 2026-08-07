# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

# Auto-run migrations on first boot (Vercel serverless: DATABASE_URL available at runtime, not build time)
if Rails.env.production?
  begin
    conn = ActiveRecord::Base.connection
    unless conn.table_exists?("schema_migrations")
      Rails.logger.info "[StageUp] schema_migrations missing - loading full schema..."
      load(Rails.root.join("db", "schema.rb"))
      Rails.logger.info "[StageUp] Schema loaded successfully."
    else
      ctx = ActiveRecord::MigrationContext.new(
        Rails.root.join("db", "migrate"),
        ActiveRecord::SchemaMigration.new(ActiveRecord::Base.connection_pool)
      )
      if ctx.needs_migration?
        Rails.logger.info "[StageUp] Running pending migrations..."
        ctx.migrate
        Rails.logger.info "[StageUp] Migrations complete."
      end
    end
  rescue => e
    Rails.logger.error "[StageUp] DB setup error: #{e.class}: #{e.message}"
  end
end

run Rails.application
Rails.application.load_server
