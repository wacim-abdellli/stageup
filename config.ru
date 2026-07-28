# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

# Auto-prepare database for serverless ephemeral environments (Vercel)
begin
  ActiveRecord::Base.establish_connection
  unless ActiveRecord::Base.connection.table_exists?('schema_migrations')
    Rails.logger.info "Preparing serverless database schema..."
    ActiveRecord::Tasks::DatabaseTasks.prepare_all
  end
rescue => e
  Rails.logger.warn "Database auto-prepare warning: #{e.message}"
end

run Rails.application
Rails.application.load_server
