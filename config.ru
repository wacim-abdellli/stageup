# This file is used by Rack-based servers to start the application.

begin
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

rescue => e
  $stderr.puts "BOOT ERROR: #{e.class}: #{e.message}"
  $stderr.puts e.backtrace.first(15).join("\n")
  run lambda { |_env|
    [500, { "Content-Type" => "text/plain" },
     ["Boot Error: #{e.class}: #{e.message}\n\n#{e.backtrace.first(15).join("\n")}"]]
  }
else
  class StageUpCssFallback
    def initialize(app)
      @app = app
    end

    def call(env)
      path = env["PATH_INFO"].to_s
      return @app.call(env) unless path.match?(%r{\A/assets/application(?:-[0-9a-f]+)?\.css\z})

      css = File.read(File.expand_path("app/assets/stylesheets/application.css", __dir__))
      polish_path = File.expand_path("public/certificate-polish.css", __dir__)
      css = "#{css}\n#{File.read(polish_path)}" if File.exist?(polish_path)

      [
        200,
        {
          "Content-Type" => "text/css; charset=utf-8",
          "Cache-Control" => "public, max-age=31536000"
        },
        [css]
      ]
    end
  end

  use StageUpCssFallback
  use Rack::Static,
    urls: [
      "/assets",
      "/favicon.ico",
      "/favicon.svg",
      "/apple-touch-icon.png",
      "/android-chrome-192.png",
      "/android-chrome-512.png",
      "/icon.png",
      "/icon.svg",
      "/logo-primary.svg",
      "/logo-light.svg",
      "/logo-monochrome.svg",
      "/manifest.json",
      "/robots.txt"
    ],
    root: "public",
    header_rules: [
      [:all, { "cache-control" => "public, max-age=31536000" }]
    ]

  run Rails.application
  Rails.application.load_server
end
