# This file is used by Rack-based servers to start the application.

APP_ROOT = __dir__
APP_CSS_PATH = File.join(APP_ROOT, "app", "assets", "stylesheets", "application.css")
CERT_POLISH_PATH = File.join(APP_ROOT, "public", "certificate-polish.css")
PUBLIC_ROOT = File.expand_path(File.join(APP_ROOT, "public"))
STATIC_PUBLIC_PATHS = {
  "/favicon.ico" => "favicon.ico",
  "/favicon.svg" => "favicon.svg",
  "/apple-touch-icon.png" => "apple-touch-icon.png",
  "/android-chrome-192.png" => "android-chrome-192.png",
  "/android-chrome-512.png" => "android-chrome-512.png",
  "/icon.png" => "icon.png",
  "/icon.svg" => "icon.svg",
  "/logo-primary.svg" => "logo-primary.svg",
  "/logo-light.svg" => "logo-light.svg",
  "/logo-monochrome.svg" => "logo-monochrome.svg",
  "/manifest.json" => "manifest.json",
  "/robots.txt" => "robots.txt"
}.freeze

def serve_application_css
  css = File.read(APP_CSS_PATH)
  css = "#{css}\n#{File.read(CERT_POLISH_PATH)}" if File.exist?(CERT_POLISH_PATH)

  [
    200,
    {
      "content-type" => "text/css; charset=utf-8",
      "cache-control" => "public, max-age=31536000"
    },
    [css]
  ]
end

def serve_public_file(relative_path)
  path = File.expand_path(File.join(PUBLIC_ROOT, relative_path))
  public_root = "#{PUBLIC_ROOT}#{File::SEPARATOR}"
  return nil unless path.start_with?(public_root) && File.file?(path)

  content_type =
    case File.extname(path)
    when ".svg" then "image/svg+xml"
    when ".ico" then "image/x-icon"
    when ".png" then "image/png"
    when ".json" then "application/json; charset=utf-8"
    when ".txt" then "text/plain; charset=utf-8"
    else "application/octet-stream"
    end

  [
    200,
    {
      "content-type" => content_type,
      "cache-control" => "public, max-age=31536000"
    },
    [File.binread(path)]
  ]
end

def boot_stageup_app
  require_relative "config/environment"

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

  Rails.application
end

rails_app = nil
boot_error = nil

run lambda { |env|
  path = env["PATH_INFO"].to_s

  if path.match?(%r{\A/assets/application(?:-[0-9a-f]+)?\.css\z})
    return serve_application_css
  end

  if path.start_with?("/assets/")
    relative_path = path.delete_prefix("/assets/")
    static_response = serve_public_file(File.join("assets", relative_path))
    return static_response if static_response
  end

  if (relative_path = STATIC_PUBLIC_PATHS[path])
    static_response = serve_public_file(relative_path)
    return static_response if static_response
  end

  begin
    rails_app ||= boot_stageup_app
    rails_app.call(env)
  rescue => e
    boot_error ||= e
    $stderr.puts "BOOT ERROR: #{e.class}: #{e.message}"
    $stderr.puts e.backtrace.first(15).join("\n")
    [
      500,
      { "content-type" => "text/plain" },
      ["Boot Error: #{boot_error.class}: #{boot_error.message}\n\n#{boot_error.backtrace.first(15).join("\n")}"]
    ]
  end
}
