# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_07_11_052557) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "commitment_events", force: :cascade do |t|
    t.string "profileable_type", null: false
    t.bigint "profileable_id", null: false
    t.string "event_type", null: false
    t.float "score_delta", default: 0.0, null: false
    t.text "description", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profileable_type", "profileable_id"], name: "index_commitment_events_on_profileable"
  end

  create_table "company_profiles", force: :cascade do |t|
    t.string "name", null: false
    t.string "website"
    t.text "description"
    t.boolean "verified", default: false, null: false
    t.float "response_rate", default: 0.0, null: false
    t.float "avg_response_time_hours", default: 0.0, null: false
    t.integer "offers_count", default: 0, null: false
    t.datetime "first_offer_posted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "missions", force: :cascade do |t|
    t.bigint "offer_id", null: false
    t.string "title", null: false
    t.text "instructions", null: false
    t.integer "estimated_duration_minutes", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["offer_id"], name: "index_missions_on_offer_id"
  end

  create_table "offers", force: :cascade do |t|
    t.bigint "company_profile_id", null: false
    t.string "title", null: false
    t.text "description", null: false
    t.string "stage_type", null: false
    t.integer "spots", default: 1, null: false
    t.string "location", null: false
    t.string "work_mode", default: "onsite", null: false
    t.string "status", default: "active", null: false
    t.datetime "deadline"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_profile_id"], name: "index_offers_on_company_profile_id"
  end

  create_table "student_profiles", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "phone"
    t.bigint "university_id"
    t.string "major"
    t.integer "graduation_year"
    t.text "bio"
    t.float "commitment_score", default: 100.0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["university_id"], name: "index_student_profiles_on_university_id"
  end

  create_table "submissions", force: :cascade do |t|
    t.bigint "student_profile_id", null: false
    t.bigint "offer_id", null: false
    t.bigint "mission_id"
    t.string "status", default: "started", null: false
    t.string "github_link"
    t.text "submission_notes"
    t.text "feedback"
    t.datetime "submitted_at"
    t.datetime "responded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["mission_id"], name: "index_submissions_on_mission_id"
    t.index ["offer_id"], name: "index_submissions_on_offer_id"
    t.index ["student_profile_id", "offer_id"], name: "index_submissions_on_student_profile_id_and_offer_id", unique: true
    t.index ["student_profile_id"], name: "index_submissions_on_student_profile_id"
  end

  create_table "universities", force: :cascade do |t|
    t.string "name", null: false
    t.string "email_domain", null: false
    t.boolean "approved", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_domain"], name: "index_universities_on_email_domain", unique: true
    t.index ["name"], name: "index_universities_on_name", unique: true
  end

  create_table "university_profiles", force: :cascade do |t|
    t.bigint "university_id", null: false
    t.string "admin_name", null: false
    t.string "department", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "approved", default: false, null: false
    t.index ["university_id"], name: "index_university_profiles_on_university_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "profileable_type", null: false
    t.bigint "profileable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["profileable_type", "profileable_id"], name: "index_users_on_profileable"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "missions", "offers"
  add_foreign_key "offers", "company_profiles"
  add_foreign_key "student_profiles", "universities"
  add_foreign_key "submissions", "missions"
  add_foreign_key "submissions", "offers"
  add_foreign_key "submissions", "student_profiles"
  add_foreign_key "university_profiles", "universities"
end
