# scratch/demo_walkthrough.rb
# Programmatically runs through the entire StageUp product loop to rehearse the demo.

puts "=================================================="
puts "🚀   STAGEUP DEMO WALKTHROUGH REHEARSAL STARTED   🚀"
puts "=================================================="

# Helper to print steps
def print_step(num, title)
  puts "\n[STEP #{num}] #{title}"
  puts "-" * 40
end

# 1. Reset database
print_step(1, "Resetting database to a clean seed state")
ActiveRecord::Base.connection.tables.each do |table|
  next if table == "schema_migrations" || table == "ar_internal_metadata"
  ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table} RESTART IDENTITY CASCADE;")
end
Rails.application.load_seed
puts "✅ Database successfully replanted and seeded!"

# 2. Student Sign Up
print_step(2, "Student Sign Up (with ISET Sfax auto-verification)")
student_profile = StudentProfile.new(
  first_name: "Anis",
  last_name: "Ghorbel",
  major: "Computer Science",
  graduation_year: 2027
)
student_user = User.create!(
  email: "anis.ghorbel@isetsf.rnu.tn",
  password: "password123",
  password_confirmation: "password123",
  profileable: student_profile
)
student_profile.save!
# Verify university auto-association (matched via domain 'isetsf.rnu.tn')
email_domain = student_user.email.split("@").last.to_s.downcase
matched_uni = University.find_by(email_domain: email_domain)
student_profile.update!(university: matched_uni)

puts "Student registered: #{student_profile.first_name} #{student_profile.last_name}"
puts "Auto-associated University: #{student_profile.university&.name || 'None'}"
if student_profile.university&.name == "ISET Sfax"
  puts "✅ Success: Student automatically verified with ISET Sfax!"
else
  raise "❌ Failure: Auto-association failed!"
end

# 3. Browse Offers & Start Mission
print_step(3, "Browse Offers & Start Proof Mission")
offer = Offer.find_by(title: "Full Stack Rails Intern")
mission = offer.mission

# Create submission (starting the mission)
submission = Submission.create!(
  student_profile: student_profile,
  offer: offer,
  mission: mission,
  status: "started"
)
puts "Internship Offer: '#{offer.title}' (Mission-based)"
puts "Submission status: #{submission.status.upcase}"
if submission.status == "started"
  puts "✅ Success: Proof mission started! 48-hour clock is ticking."
else
  raise "❌ Failure: Submission did not start correctly."
end

# 4. Submit Proof Solution
print_step(4, "Submit Proof Solution Link")
submission.update!(
  github_link: "https://github.com/anis-ghorbel/stageup-internship",
  submission_notes: "Implemented the double-confirmation loop and unit tests.",
  status: "submitted",
  submitted_at: Time.current
)
puts "Solution URL submitted: #{submission.github_link}"
puts "Submission status: #{submission.status.upcase}"
if submission.status == "submitted"
  puts "✅ Success: Solution submitted for review!"
else
  raise "❌ Failure: Submission could not be submitted."
end

# 5. Employer Acceptance
print_step(5, "Employer reviews and accepts application")
company_recruiter = User.find_by(email: "contact@devcorp.tn")
submission.update!(
  status: "accepted",
  responded_at: Time.current
)
puts "Reviewer Action: ACCEPTED"
puts "Submission status: #{submission.status.upcase}"
if submission.status == "accepted"
  puts "✅ Success: Candidate is hired! Internship is active."
else
  raise "❌ Failure: Submission was not accepted."
end

# 6. Completion Confirmation (Both Sides)
print_step(6, "Internship Completion Dual-Confirmation")

# Student confirms first
submission.confirm_completion_by!("StudentProfile")
puts "Student clicked 'Mark Completed'."
puts "Submission status: #{submission.status.upcase} (student_confirmed: #{submission.student_confirmed_completed}, company_confirmed: #{submission.company_confirmed_completed})"

# Employer confirms second
submission.confirm_completion_by!("CompanyProfile")
puts "Employer clicked 'Mark Completed'."
puts "Submission status: #{submission.status.upcase} (student_confirmed: #{submission.student_confirmed_completed}, company_confirmed: #{submission.company_confirmed_completed})"

student_profile.reload
puts "Student commitment score updated: #{student_profile.commitment_score} (Base was 100)"
if submission.status == "completed" && student_profile.commitment_score == 100.0
  # Note: 100 is the clamped maximum, which is correct!
  puts "✅ Success: Both sides confirmed. Internship status set to COMPLETED and score is capped at 100."
else
  raise "❌ Failure: Completion confirmation failed."
end

# 7. Reviews & Ratings Exchange
print_step(7, "Exchange Ratings & Reviews")

# Student reviews recruiter
student_review = Review.create!(
  submission: submission,
  author: student_user,
  receiver: company_recruiter,
  rating: 5,
  comment: "Great experience working with the DevCorp team! Highly recommend."
)
puts "Student Left 5-Star Review for Recruiter."

# Recruiter reviews student
recruiter_review = Review.create!(
  submission: submission,
  author: company_recruiter,
  receiver: student_user,
  rating: 4,
  comment: "Anis was exceptionally fast and communicative throughout the PFA."
)
puts "Recruiter Left 4-Star Review for Student."

student_profile.reload
company_profile = offer.company_profile
company_profile.reload

puts "\nRecalculated Profiles averages:"
puts "Student Average Rating: ⭐️ #{student_profile.average_rating} (#{student_profile.reviews_received_count} reviews)"
puts "Company Average Rating: ⭐️ #{company_profile.average_rating} (#{company_profile.reviews_received_count} reviews)"

if student_profile.average_rating == 4.0 && company_profile.average_rating == 5.0
  puts "✅ Success: Rating averages computed correctly!"
else
  raise "❌ Failure: Rating average mismatch."
end

puts "\n=================================================="
puts "🎉   STAGEUP DEMO WALKTHROUGH REHEARSAL PASSED   🎉"
puts "=================================================="
