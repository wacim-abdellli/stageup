# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

# Auto-run migrations on first boot (Vercel serverless: DATABASE_URL available at runtime, not build time)
if Rails.env.production?
  begin
    conn = ActiveRecord::Base.connection
    unless conn.table_exists?("schema_migrations")
      Rails.logger.info "[StageUp] schema_migrations missing — loading full schema..."
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

css_app = lambda do |env|
  path = env["PATH_INFO"].to_s

  if path.end_with?(".css") || path.include?("stylesheet")
    # Check if specific static file exists in public/
    clean_path = path.delete_prefix("/")
    public_file = Rails.root.join("public", clean_path)
    if File.file?(public_file)
      content = File.read(public_file)
      return [
        200,
        {
          "content-type" => "text/css; charset=utf-8",
          "cache-control" => "public, max-age=3600",
          "content-length" => content.bytesize.to_s
        },
        [content]
      ]
    end

    css_file = Rails.root.join("app/assets/stylesheets/application.css")
    if File.file?(css_file)
      content = File.read(css_file)
      return [
        200,
        {
          "content-type" => "text/css; charset=utf-8",
          "cache-control" => "public, max-age=3600",
          "content-length" => content.bytesize.to_s
        },
        [content]
      ]
    end
  end

  Rails.application.call(env)
end

run css_app
Rails.application.load_server

