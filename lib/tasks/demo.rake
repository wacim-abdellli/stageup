namespace :demo do
  desc "Purge all Active Storage attachments and replant database seeds"
  task reset: :environment do
    puts "Cleaning Active Storage files on disk..."
    storage_path = Rails.root.join("storage")
    if Dir.exist?(storage_path)
      # Deletes all directories and files inside storage/ without removing the directory itself
      FileUtils.rm_rf(Dir.glob("#{storage_path}/*"))
      puts "Active Storage directory purged successfully!"
    else
      puts "Active Storage directory does not exist. Skipping."
    end

    puts "\nReplanting database seeds (truncating all tables)..."
    Rake::Task["db:seed:replant"].invoke

    puts "\nDemo database reset completed successfully!"
  end
end
