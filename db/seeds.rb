# db/seeds.rb
# Idempotent seed script to populate test data for StageUp manual testing.

puts "Cleaning up old data..."
CommitmentEvent.destroy_all
InternshipAgreement.destroy_all
Submission.destroy_all
Mission.destroy_all
Offer.destroy_all

puts "Seeding Universities..."
iset_sfax = University.find_or_create_by!(email_domain: "isetsf.rnu.tn") do |u|
  u.name = "ISET Sfax"
  u.approved = true
end

enis = University.find_or_create_by!(email_domain: "enis.tn") do |u|
  u.name = "ENIS"
  u.approved = true
end

puts "Seeding Student Profiles..."
# Student 1: Mohamed Ben Ali
student_1_profile = StudentProfile.find_or_initialize_by(first_name: "Mohamed", last_name: "Ben Ali")
student_1_profile.update!(
  phone: "+216 99 123 456",
  university: iset_sfax,
  major: "Software Engineering",
  graduation_year: 2027,
  bio: "Full-Stack developer passionate about Ruby on Rails & React.",
  commitment_score: 100.0
)

user_student_1 = User.find_or_initialize_by(email: "mohamed.benali@isetsf.rnu.tn")
user_student_1.update!(
  password: "password123456",
  password_confirmation: "password123456",
  profileable: student_1_profile
)

# Student 2: Cyrine Trabelsi
student_2_profile = StudentProfile.find_or_initialize_by(first_name: "Cyrine", last_name: "Trabelsi")
student_2_profile.update!(
  phone: "+216 22 987 654",
  university: enis,
  major: "Data Science & AI",
  graduation_year: 2026,
  bio: "Data engineer looking for a PFE internship in AI/ML.",
  commitment_score: 95.0
)

user_student_2 = User.find_or_initialize_by(email: "cyrine.trabelsi@enis.tn")
user_student_2.update!(
  password: "password123456",
  password_confirmation: "password123456",
  profileable: student_2_profile
)

puts "Seeding Company Profiles..."
# Company 1: DevCorp Sfax
company_1_profile = CompanyProfile.find_or_initialize_by(name: "DevCorp Sfax")
company_1_profile.update!(
  website: "https://devcorp.tn",
  description: "A leading software agency in Sfax specializing in Web & Mobile solutions.",
  verified: true,
  response_rate: 100.0,
  avg_response_time_hours: 4.5,
  offers_count: 0
)

user_company_1 = User.find_or_initialize_by(email: "contact@devcorp.tn")
user_company_1.update!(
  password: "password123456",
  password_confirmation: "password123456",
  profileable: company_1_profile
)

# Company 2: AlphaTech Startups
company_2_profile = CompanyProfile.find_or_initialize_by(name: "AlphaTech Startups")
company_2_profile.update!(
  website: "https://alphatech.co",
  description: "AI and IoT solutions developer in Sfax and Tunis.",
  verified: true,
  response_rate: 85.0,
  avg_response_time_hours: 12.0,
  offers_count: 0
)

user_company_2 = User.find_or_initialize_by(email: "recruiting@alphatech.co")
user_company_2.update!(
  password: "password123456",
  password_confirmation: "password123456",
  profileable: company_2_profile
)

puts "Seeding University Profiles..."
uni_admin_profile = UniversityProfile.find_or_initialize_by(admin_name: "Prof. Ahmed Mansour", department: "IT Department")
uni_admin_profile.update!(
  university: iset_sfax
)

user_uni = User.find_or_initialize_by(email: "ahmed.mansour@isetsf.rnu.tn")
user_uni.update!(
  password: "password123456",
  password_confirmation: "password123456",
  profileable: uni_admin_profile
)

puts "Seeding Master Admin User..."
admin_profile = StudentProfile.find_or_initialize_by(first_name: "Wacim", last_name: "Abdelli")
admin_profile.update!(
  phone: "+216 21 666 374",
  major: "AI Engineering",
  graduation_year: 2027,
  bio: "StageUp Platform Master Administrator.",
  commitment_score: 100.0
)

master_admin = User.find_or_initialize_by(email: "wacimabdelli01@gmail.com")
master_admin.allow_admin_creation = true
master_admin.password = "password123456"
master_admin.password_confirmation = "password123456"
master_admin.profileable = admin_profile
master_admin.save!

puts "Seeding Skills..."
skill_names = %w[Ruby\ on\ Rails React Data\ Science Python SQL Docker JavaScript CSS Git Java]
skills = skill_names.map { |name| Skill.find_or_create_by!(name: name) }

student_1_profile.skills = [ skills[0], skills[1], skills[4], skills[6], skills[8] ] # Rails, React, SQL, JS, Git
student_2_profile.skills = [ skills[2], skills[3], skills[4], skills[5] ] # Data Science, Python, SQL, Docker

puts "Seeding Offers & Missions..."
offer_1 = Offer.find_or_initialize_by(title: "Full Stack Rails Intern", company_profile: company_1_profile)
offer_1.update!(
  description: "Join our team to build high-scale Rails 8 applications with Hotwire & Turbo.",
  stage_type: "PFE",
  spots: 2,
  location: "Sfax",
  work_mode: "hybrid",
  status: "active",
  deadline: 30.days.from_now
)
offer_1.skills = [ skills[0], skills[1], skills[4], skills[5], skills[6] ]

mission_1 = Mission.find_or_initialize_by(offer: offer_1)
mission_1.update!(
  title: "Rails URL Shortener Task",
  instructions: "Build a mini Rails API that shortens URLs, tracks click analytics, and includes Minitest unit tests.",
  estimated_duration_minutes: 90
)

offer_2 = Offer.find_or_initialize_by(title: "AI & Data Science Intern", company_profile: company_2_profile)
offer_2.update!(
  description: "Clean real-world telemetry data and train machine learning models for anomaly detection.",
  stage_type: "PFA",
  spots: 1,
  location: "Tunis",
  work_mode: "remote",
  status: "active",
  deadline: 20.days.from_now
)
offer_2.skills = [ skills[2], skills[3], skills[4] ]

mission_2 = Mission.find_or_initialize_by(offer: offer_2)
mission_2.update!(
  title: "Python Data Cleaning Challenge",
  instructions: "Parse a 100K row CSV dataset using Pandas, clean null values, and calculate key performance indicators.",
  estimated_duration_minutes: 120
)

puts "Seeding Submissions..."
# 1. Mohamed has started the mission on offer 1
sub_1 = Submission.find_or_initialize_by(student_profile: student_1_profile, offer: offer_1)
sub_1.update!(
  mission: mission_1,
  status: "started",
  created_at: 2.hours.ago
)

# 2. Cyrine has submitted code on offer 1 for company review
sub_2 = Submission.find_or_initialize_by(student_profile: student_2_profile, offer: offer_1)
sub_2.update!(
  mission: mission_1,
  status: "submitted",
  github_link: "https://github.com/cyrine-trabelsi/url-shortener",
  submission_notes: "Completed the URL shortener challenge in Rails 8. Included full unit test suite passing 100%.",
  submitted_at: 1.day.ago
)

company_1_profile.recalculate_metrics!
company_2_profile.recalculate_metrics!

puts "Seeding Commitment Events..."
CommitmentEvent.create!(
  profileable: student_1_profile,
  event_type: "student_completed_internship",
  score_delta: 15.0,
  description: "Completed Web Development PFE internship at DevCorp Sfax",
  created_at: 2.days.ago
)

CommitmentEvent.create!(
  profileable: company_1_profile,
  event_type: "company_responded_on_time",
  score_delta: 10.0,
  description: "Evaluated mission submission within 12 hours",
  created_at: 1.day.ago
)

CommitmentEvent.create!(
  profileable: student_2_profile,
  event_type: "student_completed_internship",
  score_delta: 15.0,
  description: "Completed Data Science PFE internship at AlphaTech Startups",
  created_at: 3.days.ago
)

CommitmentEvent.create!(
  profileable: company_2_profile,
  event_type: "company_responded_on_time",
  score_delta: 10.0,
  description: "Verified university agreement within 24h deadline",
  created_at: 4.days.ago
)

puts "Database successfully seeded!"
