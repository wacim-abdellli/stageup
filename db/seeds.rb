# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here is idempotent so that it can be executed at any point in every environment.

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
  bio: "Web developer passionate about Ruby on Rails.",
  commitment_score: 100.0
)

User.find_or_create_by!(email: "mohamed.benali@isetsf.rnu.tn") do |u|
  u.password = "password123"
  u.profileable = student_1_profile
end

# Student 2: Cyrine Trabelsi
student_2_profile = StudentProfile.find_or_initialize_by(first_name: "Cyrine", last_name: "Trabelsi")
student_2_profile.update!(
  phone: "+216 22 987 654",
  university: enis,
  major: "Data Science",
  graduation_year: 2026,
  bio: "Data engineer looking for a PFE internship.",
  commitment_score: 95.0
)

User.find_or_create_by!(email: "cyrine.trabelsi@enis.tn") do |u|
  u.password = "password123"
  u.profileable = student_2_profile
end


puts "Seeding Company Profiles..."
# Company 1: DevCorp Sfax
company_1_profile = CompanyProfile.find_or_initialize_by(name: "DevCorp Sfax")
company_1_profile.update!(
  website: "https://devcorp.tn",
  description: "A leading software agency in Sfax.",
  verified: true,
  response_rate: 100.0,
  avg_response_time_hours: 4.5,
  offers_count: 0
)

User.find_or_create_by!(email: "contact@devcorp.tn") do |u|
  u.password = "password123"
  u.profileable = company_1_profile
end

# Company 2: AlphaTech Startups
company_2_profile = CompanyProfile.find_or_initialize_by(name: "AlphaTech Startups")
company_2_profile.update!(
  website: "https://alphatech.co",
  description: "AI and IoT solutions developer in Sfax.",
  verified: false,
  response_rate: 0.0,
  avg_response_time_hours: 0.0,
  offers_count: 0
)

User.find_or_create_by!(email: "recruiting@alphatech.co") do |u|
  u.password = "password123"
  u.profileable = company_2_profile
end


puts "Seeding University Profiles..."
# Uni Admin: Ahmed Mansour (IT department head at ISET Sfax)
uni_admin_profile = UniversityProfile.find_or_initialize_by(admin_name: "Prof. Ahmed Mansour", department: "IT Department")
uni_admin_profile.update!(
  university: iset_sfax
)

User.find_or_create_by!(email: "ahmed.mansour@isetsf.rnu.tn") do |u|
  u.password = "password123"
  u.profileable = uni_admin_profile
end

puts "Seeding Skills..."
skill_names = %w[Ruby\ on\ Rails React Data\ Science Python SQL Docker JavaScript CSS Git Java]
skills = skill_names.map { |name| Skill.find_or_create_by!(name: name) }

# Associate skills with student 1 (Mohamed — Rails/JS/CSS/SQL/Git)
student_1_profile.skills << [ skills[0], skills[6], skills[7], skills[4], skills[8] ] # Rails, JS, CSS, SQL, Git

# Associate skills with student 2 (Cyrine — Data Science/Python/SQL)
student_2_profile.skills << [ skills[2], skills[3], skills[4] ] # Data Science, Python, SQL

# Associate skills with offer 1 (Full Stack Rails — Rails/React/SQL/Docker/JS/CSS/Git)
offer_1.skills << [ skills[0], skills[1], skills[4], skills[5], skills[6], skills[7], skills[8] ] # Rails, React, SQL, Docker, JS, CSS, Git

# Associate skills with offer 2 (Data Science Intern — Python/SQL/Data Science)
offer_2.skills << [ skills[2], skills[3], skills[4] ] # Data Science, Python, SQL

puts "Seeding Offers & Missions..."
offer_1 = Offer.find_or_initialize_by(title: "Full Stack Rails Intern", company_profile: company_1_profile)
offer_1.update!(
  description: "Learn Rails 8 in production.",
  stage_type: "PFE",
  spots: 2,
  location: "Sfax",
  work_mode: "hybrid",
  status: "active",
  deadline: 30.days.from_now
)

mission_1 = Mission.find_or_initialize_by(offer: offer_1)
mission_1.update!(
  title: "Rails URL Shortener Task",
  instructions: "Build a Rails API that shortens URLs. Include tests.",
  estimated_duration_minutes: 90
)

offer_2 = Offer.find_or_initialize_by(title: "Data Science Intern", company_profile: company_2_profile)
offer_2.update!(
  description: "Clean data, build models.",
  stage_type: "PFA",
  spots: 1,
  location: "Tunis",
  work_mode: "remote",
  status: "active",
  deadline: 30.days.from_now
)

puts "Seeding Submissions..."
# 1. Mohamed has started the mission on offer 1
sub_1 = Submission.find_or_initialize_by(student_profile: student_1_profile, offer: offer_1)
sub_1.update!(
  mission: mission_1,
  status: "started",
  created_at: Time.current
)

# 2. Cyrine has submitted on offer 1
sub_2 = Submission.find_or_initialize_by(student_profile: student_2_profile, offer: offer_1)
sub_2.update!(
  mission: mission_1,
  status: "submitted",
  github_link: "https://github.com/cyrine-trabelsi/url-shortener",
  submission_notes: "Here is my URL shortener code. It includes 10 unit tests.",
  submitted_at: 1.day.ago
)

company_1_profile.recalculate_metrics!
company_2_profile.recalculate_metrics!

puts "Seeding Commitment Events..."
CommitmentEvent.find_or_create_by!(
  profileable: student_1_profile,
  event_type: "student_completed_internship",
  score_delta: 15.0,
  description: "Completed Web Development PFE internship at DevCorp Sfax",
  created_at: 2.days.ago
)

CommitmentEvent.find_or_create_by!(
  profileable: company_1_profile,
  event_type: "company_responded_on_time",
  score_delta: 10.0,
  description: "Evaluated mission submission within 12 hours",
  created_at: 1.day.ago
)

CommitmentEvent.find_or_create_by!(
  profileable: student_2_profile,
  event_type: "student_completed_internship",
  score_delta: 15.0,
  description: "Completed Data Science PFE internship at AlphaTech Startups",
  created_at: 3.days.ago
)

CommitmentEvent.find_or_create_by!(
  profileable: student_1_profile,
  event_type: "student_mission_expired",
  score_delta: -10.0,
  description: "Failed to submit Rails URL Shortener Task within 48h deadline",
  created_at: 4.days.ago
)

CommitmentEvent.find_or_create_by!(
  profileable: company_2_profile,
  event_type: "company_ghosted_offer",
  score_delta: -15.0,
  description: "Failed to review student applications within 7 days",
  created_at: 5.days.ago
)

CommitmentEvent.find_or_create_by!(
  profileable: student_2_profile,
  event_type: "student_completed_internship",
  score_delta: 15.0,
  description: "Completed React frontend challenge on time",
  created_at: 6.days.ago
)

CommitmentEvent.find_or_create_by!(
  profileable: company_1_profile,
  event_type: "company_responded_late",
  score_delta: -5.0,
  description: "Delayed evaluation of candidate code challenge",
  created_at: 7.days.ago
)

CommitmentEvent.find_or_create_by!(
  profileable: student_1_profile,
  event_type: "student_completed_internship",
  score_delta: 10.0,
  description: "Successfully solved ISET Sfax verification task",
  created_at: 8.days.ago
)

puts "Seeding Admin User..."
admin_profile = StudentProfile.find_or_create_by!(first_name: "System", last_name: "Admin") do |p|
  p.phone = "+216 00 000 000"
  p.major = "Administration"
  p.graduation_year = 2030
  p.bio = "StageUp system administrator."
  p.commitment_score = 100.0
end

User.find_or_create_by!(email: "admin@stageup.tn") do |u|
  u.password = "password"
  u.allow_admin_creation = true
  u.admin = true
  u.profileable = admin_profile
end
puts "Admin user created (admin@stageup.tn / password)"

puts "Database successfully seeded!"
