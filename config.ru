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

class StageUpCssAssets
  CSS_PATTERN = %r{\A/assets/application(?:-[0-9a-f]+)?\.css\z}

  def initialize(app)
    @app = app
  end

  def call(env)
    path = env["PATH_INFO"].to_s
    return @app.call(env) unless path.match?(CSS_PATTERN)

    serve_css(path)
  rescue => e
    Rails.logger.error "[StageUpCssAssets] #{e.class}: #{e.message}"
    @app.call(env)
  end

  private

  def serve_css(request_path)
    relative = request_path.delete_prefix("/assets/")
    candidates = [
      Rails.public_path.join("assets", relative),
      Rails.public_path.join("assets", "application.css"),
      Rails.root.join("app/assets/stylesheets/application.css")
    ]

    file = candidates.find(&:file?)
    unless file
      return [
        404,
        { "content-type" => "text/plain; charset=utf-8" },
        ["application stylesheet not found"]
      ]
    end

    css = file.read
    polish = Rails.public_path.join("certificate-polish.css")
    css = "#{css}\n#{polish.read}" if polish.file?

    [
      200,
      {
        "content-type" => "text/css; charset=utf-8",
        "cache-control" => "public, max-age=31536000"
      },
      [css]
    ]
  end
end

use StageUpCssAssets
run Rails.application
Rails.application.load_server
