# This file is used by Rack-based servers to start the application.

begin
  require_relative "config/environment"
rescue => e
  # Log the actual boot error so it appears in Vercel function logs
  $stderr.puts "=" * 60
  $stderr.puts "RAILS BOOT FAILED: #{e.class}"
  $stderr.puts e.message
  $stderr.puts e.backtrace.first(20).join("\n")
  $stderr.puts "=" * 60
  $stderr.flush

  # Return a minimal Rack response showing the real error
  run lambda { |_env|
    body = "Boot Error: #{e.class}: #{e.message}"
    [500, { "Content-Type" => "text/plain" }, [body]]
  }
else
  run Rails.application
  Rails.application.load_server
end
