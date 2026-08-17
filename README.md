<div align="center">

# StageUp 🎓

**Tunisia's first verified internship platform.**  
Proof-of-work missions · Reputation scoring · Official Convention de Stage · 300+ Skills Catalog

[![Ruby](https://img.shields.io/badge/Ruby-3.3.11-CC342D?logo=ruby&logoColor=white)](https://www.ruby-lang.org/)
[![Rails](https://img.shields.io/badge/Rails-8.1.3-CC0000?logo=rubyonrails&logoColor=white)](https://rubyonrails.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-336791?logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Tests](https://img.shields.io/badge/Tests-201_passing-brightgreen?logo=checkmarx&logoColor=white)](#running-the-test-suite)
[![Security](https://img.shields.io/badge/Security-Audited-blueviolet?logo=shieldsdotio&logoColor=white)](#security)
[![i18n](https://img.shields.io/badge/Locales-EN%20%7C%20FR%20%7C%20AR-orange?logo=translate&logoColor=white)](#-internationalization-i18n)

</div>

---

## 📌 Table of Contents

- [What Is StageUp?](#what-is-stageup)
- [Who Uses It](#who-uses-it)
- [Core Features](#core-features)
  - [Proof-of-Work Missions](#proof-of-work-missions)
  - [Commitment Score System](#commitment-score-system)
  - [Convention de Stage](#convention-de-stage)
  - [300+ Industry Skills Catalog](#300-industry-skills-catalog)
  - [Trilingual Support (EN / FR / AR)](#-internationalization-i18n)
- [Tech Stack](#tech-stack)
- [Getting Started](#getting-started)
  - [Option A — Docker Setup (Recommended)](#option-a--docker-setup-recommended)
  - [Option B — Local Setup](#option-b--local-setup)
- [Environment Variables](#environment-variables)
- [Running the Test Suite](#running-the-test-suite)
- [Background Jobs](#background-jobs)
- [Project Structure](#project-structure)
- [Security & Architecture](#security)
- [Deployment](#deployment)
- [License](#license)

---

## What Is StageUp?

StageUp solves a real structural problem in the Tunisian job market: **internship ghosting**. Companies ghost students after offers. Students abandon internships without notice. Nobody is held accountable.

StageUp fixes this with four core mechanisms:

- **Proof-of-Work Missions** — Companies attach real coding or design tasks to internship offers. Students submit solutions within 48 hours to demonstrate skills before applications are reviewed.
- **Commitment Scores** — Every user (student and company) maintains a public reputation score tracking reliability over time. Late responses or abandonments deduct points; on-time actions earn points.
- **Official Agreements** — Accepted internships generate a legally-structured *Convention de Stage* requiring digital signatures from student, company representative, and university coordinator.
- **300+ Skills Engine** — A deep-dive catalog of 300+ categorized skills across 15 engineering and business disciplines powering candidate-offer skill matching.

---

## Who Uses It

| Role | Capabilities |
|------|--------------|
| **Student** | Browse verified offers, complete proof missions, manage application Kanban status, sign *Conventions de Stage*, leave company reviews |
| **Company** | Post offers with optional missions, manage applications via Kanban board, accept/reject candidates, track response times, review active interns |
| **University Coordinator** | Monitor enrolled students, review and digitally sign *Conventions de Stage*, verify completion certificates |
| **Master Admin** | Verify company profiles (domain-matching badge), approve/revoke coordinators, inspect user audit logs, grant/revoke admin roles |

---

## Core Features

### Proof-of-Work Missions
When a company creates an offer, they can attach an optional mission (coding challenge, design brief, or data task). When a student applies, they accept the task and have **48 hours** to submit their solution via GitHub, Figma, or public URL. Solutions are verified automatically via repo inspection and file checking.

### Commitment Score System
Every user starts with a **100/100** reputation score:

| Event | Score Delta |
|-------|-------------|
| Company responds to application on time (< 14 days) | **+1** |
| Company responds late (14+ days) | **-5** |
| Company ghosts an application (no response) | **-15** |
| Student completes an internship | **+15** |
| Student abandons an active internship | **-25** |
| Student proof mission expires (2nd+ time) | **-10** |

### Convention de Stage
When a student is accepted, either party generates a structured 3-party agreement (*Convention de Stage*) requiring digital signatures from:
1. Student
2. Company Representative  
3. University Coordinator (if enrolled at a partner institution)

### 300+ Industry Skills Catalog
A 15-category skill ecosystem spanning:
- *Backend & Web Architecture* (Rails, Node, Django, Go, Spring, PostgreSQL, Redis)
- *Frontend Engineering* (React, Next.js, Vue, TypeScript, Tailwind CSS, WebAssembly)
- *Data Science & AI* (PyTorch, TensorFlow, LLMs, RAG, Prompt Engineering, PowerBI)
- *DevOps & Cloud* (Docker, Kubernetes, AWS, Terraform, CI/CD)
- *Design & UI/UX* (Figma, Design Systems, Adobe Suite, Motion Graphics, Blender)
- *Engineering* (SolidWorks, CATIA, FEA/ANSYS, PCB Design, Microcontrollers, Revit BIM)
- *Business & Management* (Digital Marketing, SEO, CRM, Agile, Talent Acquisition)

### 🌍 Internationalization (I18n)
Full native trilingual support (**English, French, Arabic**). All headings, button labels, notifications, and form validation errors are localized with right-to-left (RTL) compatibility.

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **Framework** | Ruby on Rails 8.1 |
| **Language** | Ruby 3.3.11 |
| **Database** | PostgreSQL 16 (`pg_trgm` fuzzy search + GIN indexing) |
| **Background Processing** | Solid Queue (DB-backed queue worker) |
| **Cache & Real-time** | Solid Cache + ActionCable (Solid Cable) |
| **Storage** | Active Storage → AWS S3 (production) |
| **Authentication** | Devise (lockable, timeoutable, trackable) |
| **Frontend** | Hotwire (Turbo Drive + Frame + Streams, Stimulus) |
| **Styling** | Vanilla CSS (Vercel/Linear dark-mode aesthetic with semantic tokens) |
| **Security Scanning** | Brakeman + Rack::Attack rate-limiting |
| **Deployment** | Docker + Kamal |

---

## Getting Started

### Option A — Docker Setup (Recommended)

```bash
# 1. Clone repository
git clone https://github.com/wacim-abdellli/stageup.git
cd stageup

# 2. Copy environment file
cp .env.example .env

# 3. Spin up containers
docker compose up -d

# 4. Initialize database and seed 300+ skills
docker compose exec web rails db:create db:migrate db:seed
```

App available at **http://localhost:3000**

---

### Option B — Local Setup

```bash
# 1. Clone repository & install dependencies
git clone https://github.com/wacim-abdellli/stageup.git
cd stageup
bundle install

# 2. Configure environment
cp .env.example .env

# 3. Create database & seed 300+ skills
rails db:create db:migrate db:seed

# 4. Start development server
rails server
```

Visit **http://localhost:3000**

---

## Environment Variables

Copy `.env.example` to `.env` and fill in values:

| Variable | Purpose | Environment |
|----------|---------|-------------|
| `POSTGRES_USER` | Database username | Dev / Docker |
| `POSTGRES_PASSWORD` | Database password | Dev / Docker |
| `POSTGRES_HOST` | Database host (`db` in Docker) | Dev / Docker |
| `APP_HOST` | Production domain (`stageup.tn`) | Production |
| `APP_DATABASE_PASSWORD` | Production database password | Production |
| `AWS_REGION` | S3 region | Production |
| `AWS_S3_BUCKET` | S3 storage bucket | Production |
| `SMTP_HOST` | SMTP server (`smtp.postmarkapp.com`) | Production |
| `SMTP_USERNAME` | SMTP API username | Production |
| `SMTP_PASSWORD` | SMTP API key | Production |
| `DEVISE_MAILER_SENDER` | Sender email address | Production |
| `RAILS_MASTER_KEY` | Master key for encrypted credentials | Production |

---

## Running the Test Suite

The test suite covers **201 runs** with **681 assertions** across 28 test files with zero failures:

```bash
# Run full test suite
rails test

# Run specific test file
rails test test/controllers/submissions_controller_test.rb

# Run specific test method
rails test test/controllers/offers_controller_test.rb -n "test_company_user_can_create_offer"
```

---

## Background Jobs

Powered by **Solid Queue**. Recurring tasks configured in `config/recurring.yml`:

| Job | Schedule | Description |
|-----|----------|-------------|
| `ReputationTrackerJob` | Daily at midnight | Applies ghosting penalties to companies inactive for 14+ days |
| `ResolveExpiredSubmissionsJob` | Hourly | Expires unsubmitted proof missions (48h timeout) and auto-completes internships |

Run job worker in development:
```bash
rails jobs:work
```

---

## Project Structure

```
app/
  controllers/              → 19 controllers (13 user-facing + 6 admin)
    admin/                  → Company verification, coordinator approval, user audit
    submissions_controller.rb   → Role-scoped application lifecycle
    offers_controller.rb        → Offer CRUD & match breakdown
    internship_agreements_controller.rb → 3-party agreement signing
  models/
    user.rb                 → Devise auth, polymorphic profile, attr_readonly :admin
    student_profile.rb      → CV, skills, commitment score (with_lock)
    company_profile.rb      → Offers, response metrics, reputation (with_lock)
    university_profile.rb   → Coordinator approval gate
    submission.rb           → Application state machine
    offer.rb                → Postings & mission attachments
    internship_agreement.rb → Legally-structured Convention de Stage (with_lock)
    commitment_event.rb     → Audit trail for score history
    review.rb               → Post-internship ratings
  jobs/
    verify_submission_job.rb → Git repo verification (Open3, 100MB limit)
    reputation_tracker_job.rb → Daily ghosting penalty sweep
    resolve_expired_submissions_job.rb → Hourly expiration sweep
db/
  migrate/                  → 34 migrations (17 foreign keys, pg_trgm GIN indexes)
  seeds.rb                  → Main database seeder
  seeds_skills.rb           → 300+ skills catalog seeder
```

---

## Security

### Authentication & Access Control
- Passwords enforce **minimum 12 characters**.
- Accounts lock after **10 failed login attempts** (unlockable via email token).
- Sessions timeout after **30 minutes** of inactivity.
- Admin privilege escalation blocked via `attr_readonly :admin` and creation validations.
- Rate-limiting on auth routes via `Rack::Attack`.

### IDOR & Authorization Scoping
- All mutable controller actions enforce query-scoped access (`current_user.profileable.resources.find`).
- Submissions enforce 3-way role scoping (Student / Company / University Coordinator).
- University coordinators require `approved?` + `university_id` match.

### Concurrency & Data Integrity
- **9 row-locked mutations** (`with_lock`) wrap all score recalculations, state transitions, and agreement signatures inside explicit database transactions.
- Unique composite index on `submissions(student_profile_id, offer_id)`.
- 17 foreign key constraints enforced in PostgreSQL.

---

## Deployment

Deploy via **Kamal** to any Linux server with Docker:

```bash
# Deploy to server
kamal deploy

# Run remote database migrations
kamal app exec 'rails db:migrate'
```

---

## License

Proprietary software. All rights reserved.

<div align="center">
Built with ❤️ in Tunisia · Powered by StageUp Team
</div>
