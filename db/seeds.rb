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

puts "Database successfully seeded!"
