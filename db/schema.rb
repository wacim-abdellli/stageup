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

ActiveRecord::Schema[8.1].define(version: 2026_07_18_064429) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "commitment_events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.string "event_type", null: false
    t.bigint "profileable_id", null: false
    t.string "profileable_type", null: false
    t.float "score_delta", default: 0.0, null: false
    t.datetime "updated_at", null: false
    t.index ["profileable_type", "profileable_id", "created_at"], name: "index_commitment_events_on_profile_and_created_at"
    t.index ["profileable_type", "profileable_id"], name: "index_commitment_events_on_profileable"
  end

  create_table "company_profiles", force: :cascade do |t|
    t.float "avg_response_time_hours", default: 0.0, null: false
    t.float "cached_average_rating"
    t.float "commitment_score", default: 100.0, null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "first_offer_posted_at"
    t.string "name", null: false
    t.integer "offers_count", default: 0, null: false
    t.float "response_rate", default: 0.0, null: false
    t.datetime "updated_at", null: false
    t.boolean "verified", default: false, null: false
    t.string "website"
  end

  create_table "internship_agreements", force: :cascade do |t|
    t.datetime "company_signed_at"
    t.datetime "created_at", null: false
    t.date "end_date", null: false
    t.text "rejection_reason"
    t.date "start_date", null: false
    t.string "status", default: "pending_signatures", null: false
    t.datetime "student_signed_at"
    t.bigint "submission_id", null: false
    t.datetime "university_signed_at"
    t.datetime "updated_at", null: false
    t.index ["submission_id"], name: "index_internship_agreements_on_submission_id", unique: true
  end

  create_table "missions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "estimated_duration_minutes", null: false
    t.text "instructions", null: false
    t.bigint "offer_id", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["offer_id"], name: "index_missions_on_offer_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "action", null: false
    t.datetime "created_at", null: false
    t.string "message", null: false
    t.bigint "notifiable_id", null: false
    t.string "notifiable_type", null: false
    t.boolean "read", default: false, null: false
    t.bigint "recipient_id", null: false
    t.string "recipient_type", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_notifications_on_created_at"
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable"
    t.index ["recipient_id", "recipient_type", "read"], name: "idx_on_recipient_id_recipient_type_read_f9827f957f"
    t.index ["recipient_type", "recipient_id"], name: "index_notifications_on_recipient"
  end

  create_table "offers", force: :cascade do |t|
    t.bigint "company_profile_id", null: false
    t.datetime "created_at", null: false
    t.datetime "deadline"
    t.text "description", null: false
    t.string "location", null: false
    t.integer "spots", default: 1, null: false
    t.string "stage_type", null: false
    t.string "status", default: "active", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "work_mode", default: "onsite", null: false
    t.index ["company_profile_id"], name: "index_offers_on_company_profile_id"
    t.index ["status"], name: "index_offers_on_status"
  end

  create_table "offers_skills", id: false, force: :cascade do |t|
    t.bigint "offer_id", null: false
    t.bigint "skill_id", null: false
    t.index ["offer_id", "skill_id"], name: "index_offers_skills_on_offer_id_and_skill_id", unique: true
    t.index ["offer_id"], name: "index_offers_skills_on_offer_id"
    t.index ["skill_id"], name: "index_offers_skills_on_skill_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.bigint "author_id", null: false
    t.text "comment", null: false
    t.datetime "created_at", null: false
    t.integer "rating", null: false
    t.bigint "receiver_id", null: false
    t.bigint "submission_id", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_reviews_on_author_id"
    t.index ["receiver_id"], name: "index_reviews_on_receiver_id"
    t.index ["submission_id", "author_id"], name: "index_reviews_on_submission_id_and_author_id", unique: true
    t.index ["submission_id"], name: "index_reviews_on_submission_id"
  end

  create_table "skills", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_skills_on_name", unique: true
  end

  create_table "skills_student_profiles", id: false, force: :cascade do |t|
    t.bigint "skill_id", null: false
    t.bigint "student_profile_id", null: false
    t.index ["skill_id"], name: "index_skills_student_profiles_on_skill_id"
    t.index ["student_profile_id", "skill_id"], name: "idx_on_student_profile_id_skill_id_3ee3308497", unique: true
    t.index ["student_profile_id"], name: "index_skills_student_profiles_on_student_profile_id"
  end

  create_table "student_profiles", force: :cascade do |t|
    t.text "bio"
    t.float "cached_average_rating"
    t.float "commitment_score", default: 100.0, null: false
    t.datetime "created_at", null: false
    t.string "first_name", null: false
    t.integer "graduation_year"
    t.string "last_name", null: false
    t.string "major"
    t.string "phone"
    t.bigint "university_id"
    t.datetime "updated_at", null: false
    t.index ["university_id"], name: "index_student_profiles_on_university_id"
  end

  create_table "submissions", force: :cascade do |t|
    t.text "auto_verification_log"
    t.string "auto_verification_status", default: "pending", null: false
    t.boolean "company_confirmed_completed", default: false, null: false
    t.datetime "created_at", null: false
    t.text "feedback"
    t.datetime "first_completion_confirmed_at"
    t.string "github_link"
    t.bigint "mission_id"
    t.bigint "offer_id", null: false
    t.datetime "responded_at"
    t.string "status", default: "started", null: false
    t.boolean "student_confirmed_completed", default: false, null: false
    t.bigint "student_profile_id", null: false
    t.text "submission_notes"
    t.datetime "submitted_at"
    t.datetime "updated_at", null: false
    t.index ["mission_id"], name: "index_submissions_on_mission_id"
    t.index ["offer_id", "status"], name: "index_submissions_on_offer_id_and_status"
    t.index ["offer_id"], name: "index_submissions_on_offer_id"
    t.index ["status"], name: "index_submissions_on_status"
    t.index ["student_profile_id", "offer_id"], name: "index_submissions_on_student_profile_id_and_offer_id", unique: true
    t.index ["student_profile_id", "status"], name: "index_submissions_on_student_profile_id_and_status"
    t.index ["student_profile_id"], name: "index_submissions_on_student_profile_id"
  end

  create_table "universities", force: :cascade do |t|
    t.boolean "approved", default: false, null: false
    t.datetime "created_at", null: false
    t.string "email_domain", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["email_domain"], name: "index_universities_on_email_domain", unique: true
    t.index ["name"], name: "index_universities_on_name", unique: true
  end

  create_table "university_profiles", force: :cascade do |t|
    t.string "admin_name", null: false
    t.boolean "approved", default: false, null: false
    t.datetime "created_at", null: false
    t.string "department", null: false
    t.bigint "university_id", null: false
    t.datetime "updated_at", null: false
    t.index ["university_id"], name: "index_university_profiles_on_university_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.datetime "locked_at"
    t.bigint "profileable_id", null: false
    t.string "profileable_type", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "sign_in_count", default: 0, null: false
    t.string "unlock_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["profileable_type", "profileable_id"], name: "index_users_on_profileable"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "internship_agreements", "submissions"
  add_foreign_key "missions", "offers"
  add_foreign_key "offers", "company_profiles"
  add_foreign_key "offers_skills", "offers"
  add_foreign_key "offers_skills", "skills"
  add_foreign_key "reviews", "submissions"
  add_foreign_key "reviews", "users", column: "author_id"
  add_foreign_key "reviews", "users", column: "receiver_id"
  add_foreign_key "skills_student_profiles", "skills"
  add_foreign_key "skills_student_profiles", "student_profiles"
  add_foreign_key "student_profiles", "universities"
  add_foreign_key "submissions", "missions"
  add_foreign_key "submissions", "offers"
  add_foreign_key "submissions", "student_profiles"
  add_foreign_key "university_profiles", "universities"
end
