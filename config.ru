# This file is used by Rack-based servers to start the application.

begin
  require_relative "config/environment"
rescue => e
  $stderr.puts "RAILS BOOT FAILED: #{e.class}: #{e.message}"
  $stderr.puts e.backtrace.first(20).join("\n")
  $stderr.flush
  run lambda { |_env|
    body = "Boot Error: #{e.class}: #{e.message}\n\n#{e.backtrace.first(20).join("\n")}"
    [500, { "Content-Type" => "text/plain" }, [body]]
  }
else
  # Middleware to expose runtime errors on Vercel (remove after debugging)
  class VercelErrorReporter
    def initialize(app)
      @app = app
    end

    def call(env)
      @app.call(env)
    rescue => e
      $stderr.puts "RUNTIME ERROR: #{e.class}: #{e.message}"
      $stderr.puts e.backtrace.first(20).join("\n")
      body = "Runtime Error: #{e.class}\n#{e.message}\n\n#{e.backtrace.first(20).join("\n")}"
      [500, { "Content-Type" => "text/plain" }, [body]]
    end
  end

  use VercelErrorReporter
  run Rails.application
  Rails.application.load_server
end
