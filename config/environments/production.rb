require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings (ignored by Rake tasks).
  config.eager_load = true

  # Full error reports are disabled.
  config.consider_all_requests_local = false

  # Turn on fragment caching in view templates.
  config.action_controller.perform_caching = true

  # Cache assets for far-future expiry since they are all digest stamped.
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  # Enable serving of static files from the /public folder
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present? || ENV["VERCEL"].present? || true

  # Secret key base must be set via environment variable in production.
  # On Vercel/Railway/Render, set SECRET_KEY_BASE in the dashboard.
  config.secret_key_base = ENV["SECRET_KEY_BASE"].presence || "stageup_dummy_secret_key_base_for_assets_precompilation_0123456789abcdef"

  # Don't crash if RAILS_MASTER_KEY is missing — credentials are optional on Vercel
  config.require_master_key = false

  # Store uploaded files on the local file system (see config/storage.yml for options).
  # WARNING: :local storage is volatile — files will be lost on deploy/restart in containerized environments.
  # Migrate to :amazon (S3) or :google (GCS) before production launch.
  # To migrate existing blobs, use `rails active_storage:update_migrate_service`.
  config.active_storage.service = ENV["VERCEL"].present? ? :local : :amazon

  # Assume all access to the app is happening through an SSL-terminating reverse proxy (Vercel edge).
  # Required so Rails recognizes request.scheme as "https" and matches Origin headers for CSRF protection.
  config.assume_ssl = true
  config.force_ssl = true

  # Skip http-to-https redirect for the default health check endpoint.
  config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  # Log to STDOUT with the current request id as a default log tag.
  config.log_tags = [ :request_id ]
  config.logger   = ActiveSupport::TaggedLogging.logger(STDOUT)

  # Change to "debug" to log everything (including potentially personally-identifiable information!)
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Prevent health checks from clogging up the logs.
  config.silence_healthcheck_path = "/up"

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Use in-memory cache and async job queue — no database tables needed for serverless Vercel.
  # solid_cache and solid_queue require DB tables that don't work in serverless.
  config.cache_store = :memory_store
  config.active_job.queue_adapter = :async

  # Do not raise email delivery errors in production if SMTP server is unconfigured or unreachable.
  config.action_mailer.raise_delivery_errors = false

  # Set host to be used by links generated in mailer templates.
  config.action_mailer.default_url_options = { host: ENV.fetch("APP_HOST", "stageup-ten.vercel.app"), protocol: "https" }

  # Specify outgoing SMTP server. Set SMTP_HOST, SMTP_PORT, SMTP_USERNAME, and SMTP_PASSWORD via env vars.
  config.action_mailer.delivery_method = :smtp
  smtp_port = ENV.fetch("SMTP_PORT", 587).to_i
  config.action_mailer.smtp_settings = {
    address: ENV.fetch("SMTP_HOST", "smtp.postmarkapp.com"),
    port: smtp_port,
    user_name: ENV.fetch("SMTP_USERNAME", ""),
    password: ENV.fetch("SMTP_PASSWORD", ""),
    authentication: ENV.fetch("SMTP_AUTHENTICATION", "plain").to_sym,
    enable_starttls_auto: smtp_port != 465,
    ssl: smtp_port == 465
  }

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Only use :id for inspections in production.
  config.active_record.attributes_for_inspect = [ :id ]

  # Enable DNS rebinding protection and allow Vercel host headers.
  config.hosts = [
    ENV.fetch("APP_HOST", "stageup-ten.vercel.app"),
    /.*\.vercel\.app\z/,
    /.*\.render\.com\z/
  ]

  # Skip DNS rebinding protection for the default health check endpoint.
  config.host_authorization = { exclude: ->(request) { request.path == "/up" } }
end
