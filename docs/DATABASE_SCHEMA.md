# 🗄️ StageUp Database Schema Reference

This document maps all database tables, polymorphic associations, foreign keys, and indexes defined in `db/schema.rb`.

---

## 📐 1. Entity-Relationship Overview

```
                      ┌───────────────┐
                      │  universities │
                      └───────┬───────┘
                              │
             ┌────────────────┴────────────────┐
             ▼                                 ▼
┌─────────────────────────┐       ┌─────────────────────────┐
│   student_profiles      │       │   university_profiles   │
└────────────┬────────────┘       └─────────────────────────┘
             │
             ├─────────────────────────────────┐
             ▼                                 ▼
┌─────────────────────────┐       ┌─────────────────────────┐
│       submissions       │       │ commitment_events (poly)│
└────────────┬────────────┘       └─────────────────────────┘
             │
     ┌───────┴───────┬─────────────────────────┐
     ▼               ▼                         ▼
┌─────────┐ ┌───────────────────┐     ┌───────────────────┐
│ reviews │ │internship_agreements│   │   notifications   │
└─────────┘ └───────────────────┘     └───────────────────┘
```

---

## 📋 2. Detailed Table Specifications

### 2.1 Core Identity & Profiles

#### `users`
- **Purpose**: Devise authentication table linked to polymorphic profiles.
- **Columns**: `id`, `email`, `encrypted_password`, `admin` (bool, default `false`), `profileable_type` (string), `profileable_id` (bigint), `locked_at`, `failed_attempts`.
- **Indexes**:
  - `index_users_on_email` (`UNIQUE`)
  - `index_users_on_profileable` (`profileable_type`, `profileable_id`)
  - `index_users_on_reset_password_token` (`UNIQUE`)

#### `student_profiles`
- **Purpose**: Profile data for student candidates.
- **Columns**: `id`, `first_name`, `last_name`, `bio`, `cv_url`, `commitment_score` (float, default `100.0`), `graduation_year`, `major`, `phone`, `university_id` (FK -> `universities`).
- **Foreign Keys**: `university_id` -> `universities.id`.

#### `company_profiles`
- **Purpose**: Profile & reputation metrics for recruiting companies.
- **Columns**: `id`, `name`, `description`, `website`, `commitment_score` (float, default `100.0`), `verified` (bool, default `false`), `avg_response_time_hours`, `response_rate`, `offers_count`.

#### `university_profiles` & `universities`
- **Purpose**: Academic institution directory and coordinator access.
- **`universities`**: `name` (`UNIQUE`), `email_domain` (`UNIQUE`), `approved` (bool).
- **`university_profiles`**: `admin_name`, `department`, `approved` (bool), `university_id` (FK -> `universities.id`).

---

### 2.2 Offers & Missions

#### `offers`
- **Columns**: `id`, `company_profile_id` (FK), `title`, `description`, `location`, `work_mode` (`onsite`, `remote`, `hybrid`), `stage_type` (`PFA`, `PFE`, `Initiation`), `spots` (default `1`), `status` (default `active`), `deadline`.
- **Indexes**: `company_profile_id`, `status`, `[company_profile_id, status]`.

#### `missions`
- **Columns**: `id`, `offer_id` (FK -> `offers.id`), `title`, `instructions`, `estimated_duration_minutes`.

---

### 2.3 Submissions, Agreements & Reputation

#### `submissions`
- **Columns**: `id`, `student_profile_id` (FK), `offer_id` (FK), `mission_id` (FK, nullable), `status` (default `started`), `auto_verification_status` (`pending`, `passed`, `failed`), `github_link`, `submission_notes`, `student_confirmed_completed`, `company_confirmed_completed`.
- **Indexes**:
  - `index_submissions_on_student_profile_id_and_offer_id` (`UNIQUE` - prevents duplicate applications)
  - `index_submissions_on_status`

#### `internship_agreements`
- **Columns**: `id`, `submission_id` (FK -> `submissions.id`), `start_date`, `end_date`, `status` (`pending_signatures`, `signed`, `rejected`), `student_signed_at`, `company_signed_at`, `university_signed_at`, `rejection_reason`.
- **Indexes**: `index_internship_agreements_on_submission_id` (`UNIQUE`).

#### `commitment_events`
- **Columns**: `id`, `profileable_type`, `profileable_id`, `event_type`, `description`, `score_delta` (default `0.0`).
- **Indexes**: `index_commitment_events_on_profile_and_created_at`.

#### `reviews`
- **Columns**: `id`, `submission_id` (FK), `author_id` (FK -> `users.id`), `receiver_id` (FK -> `users.id`), `rating` (integer 1-5), `comment`.
- **Indexes**: `index_reviews_on_submission_id_and_author_id` (`UNIQUE`).
