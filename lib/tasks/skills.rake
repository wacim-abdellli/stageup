namespace :skills do
  desc "Seed and categorize all 300+ skills across 15 domains"
  task seed: :environment do
    puts "Seeding categorized skills from db/seeds_skills.rb..."
    load Rails.root.join("db", "seeds_skills.rb")
  end
end
