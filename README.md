<div align="center">

# StageUp 🎓

**Tunisia's first verified internship platform.**
Proof-of-work missions · Reputation scoring · Official Convention de Stage

[![Ruby](https://img.shields.io/badge/Ruby-3.3.11-CC342D?logo=ruby&logoColor=white)](https://www.ruby-lang.org/)
[![Rails](https://img.shields.io/badge/Rails-8.1-CC0000?logo=rubyonrails&logoColor=white)](https://rubyonrails.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-336791?logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![CI](https://github.com/your-org/stageup/actions/workflows/ci.yml/badge.svg)](https://github.com/your-org/stageup/actions)

</div>

---

## What Is StageUp?

StageUp solves a real problem in the Tunisian job market: internship ghosting. Companies ghost students after offers. Students abandon internships without notice. Nobody is held accountable.

StageUp fixes this with three core mechanisms:

- **Proof-of-Work Missions** — Companies can attach a real coding/design task to an offer. Students must complete it within 48 hours before their application is considered. No more "I'm very motivated" cover letters.
- **Commitment Scores** — Every party (student, company) has a public reputation score that tracks their reliability over time. Ghost an application? Lose points. Respond on time? Gain points.
- **Official Agreements** — Internships that reach the offer stage generate a legally-structured *Convention de Stage* that requires signatures from the student, company, and university coordinator before either side can confirm completion.

---

## Who Uses It

| Role | What They Can Do |
|------|-----------------|
| **Student** | Browse offers, complete proof missions, track applications, sign agreements, leave reviews |
| **Company** | Post offers with optional missions, review applications, accept/reject candidates, manage active internships |
| **University Coordinator** | Monitor all students from their institution, review agreements, sign off on completions |
| **Admin** | Verify company accounts, approve university coordinators |

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Ruby on Rails 8.1 |
| Language | Ruby 3.3.11 |
| Database | PostgreSQL 16 |
| Background Jobs | Solid Queue |
| Cache | Solid Cache (DB-backed) |
| WebSockets | Solid Cable |
| File Storage | Active Storage → AWS S3 (production) |
| Auth | Devise (with lockable, timeoutable) |
| Rate Limiting | Rack::Attack |
| Frontend | Hotwire (Turbo + Stimulus), Propshaft |
| Deployment | Kamal + Docker |
| CI | GitHub Actions |

---

## Getting Started

### Prerequisites

Make sure you have these installed:

- **Ruby** 3.3.11 — use [rbenv](https://github.com/rbenv/rbenv) or [asdf](https://asdf-vm.com/)
- **PostgreSQL** 16+
- **Docker & Docker Compose** (for the containerized dev setup)

---

### Option A — Docker (Recommended, Zero Config)

The fastest way to get running:

```bash
# 1. Clone the repo
git clone https://github.com/your-org/stageup.git
cd stageup

# 2. Copy environment variables
cp .env.example .env

# 3. Start everything (database + web server)
docker compose up

# 4. In a separate terminal, set up the database
docker compose exec web rails db:create db:migrate db:seed
```

The app will be available at **http://localhost:3000**

---

### Option B — Local Setup

```bash
# 1. Clone and enter the project
git clone https://github.com/your-org/stageup.git
cd stageup

# 2. Install Ruby dependencies
bundle install

# 3. Set up the database
rails db:create db:migrate db:seed

# 4. Start the development server
rails server
```

Visit **http://localhost:3000**

---

## Environment Variables

Copy `.env.example` to `.env` and fill in the values:

```bash
cp .env.example .env
```

| Variable | Description | Required |
|----------|-------------|----------|
| `POSTGRES_USER` | Database username | Dev only |
| `POSTGRES_PASSWORD` | Database password | Dev only |
| `POSTGRES_HOST` | Database host (`db` in Docker) | Dev only |
| `APP_HOST` | Your production domain (e.g. `stageup.tn`) | Production |
| `APP_DATABASE_PASSWORD` | Production database password | Production |
| `AWS_REGION` | S3 bucket region | Production |
| `AWS_S3_BUCKET` | S3 bucket name for file uploads | Production |
| `SMTP_HOST` | SMTP server (e.g. `smtp.postmarkapp.com`) | Production |
| `SMTP_USERNAME` | SMTP username / API key | Production |
| `SMTP_PASSWORD` | SMTP password | Production |
| `DEVISE_MAILER_SENDER` | From address for emails | Production |
| `RAILS_MASTER_KEY` | Rails credentials master key | Production |

AWS credentials (`access_key_id`, `secret_access_key`) are stored securely in Rails encrypted credentials:

```bash
rails credentials:edit
```

---

## Running the Test Suite

```bash
# Run all tests
rails test

# Run system tests (requires Chrome)
rails test:system

# Run a specific test file
rails test test/controllers/submissions_controller_test.rb
```

---

## Background Jobs

StageUp uses **Solid Queue** for background processing. Two critical jobs run on a schedule:

| Job | Schedule | What It Does |
|-----|----------|-------------|
| `ReputationTrackerJob` | Daily at midnight | Penalizes companies who haven't responded to applications in 14+ days |
| `ResolveExpiredSubmissionsJob` | Every hour | Expires unsubmitted proof missions (48h timeout), auto-completes internships after 7-day confirmation window |

Start the job worker alongside your web server:

```bash
# In development, run in a separate terminal
rails jobs:work

# Or with Docker
docker compose exec web rails jobs:work
```

---

## Key Features In-Depth

### Proof-of-Work Missions
When a company creates an offer, they can optionally attach a mission — a real task (a coding challenge, a design brief, a short analysis). When a student applies, they accept the mission and have **48 hours** to submit their solution via GitHub, Figma, or any public URL. The link is automatically verified by cloning the repo and checking for required files. Failing to submit within 48 hours impacts the student's commitment score.

### Commitment Score System
Every user (student and company) starts at **100/100**. Actions change this score:

| Event | Delta |
|-------|-------|
| Company responds to application on time (< 14 days) | +1 |
| Company responds late | -5 |
| Company ghosts an application (14+ days, no response) | -15 |
| Student completes an internship | +15 |
| Student abandons an active internship | -25 |
| Student's proof mission expires (2nd+ time) | -10 |

Scores are visible on offer pages, so students can see how reliable a company is before applying.

### Convention de Stage
When a student is accepted, either party can generate a *Convention de Stage* — a structured internship agreement document. It requires three digital signatures:
1. The student
2. The company representative  
3. A university coordinator (if the student is affiliated with a partner university)

Only after all three signatures does the internship move toward formal completion.

---

## Project Structure

```
app/
  controllers/
    admin/            → Company verification, university approval
    users/            → Custom Devise registration with role selection
    submissions_controller.rb   → Full application lifecycle
    offers_controller.rb        → Offer management
    internship_agreements_controller.rb
    dashboards_controller.rb    → Role-specific dashboards
    reviews_controller.rb
  models/
    user.rb                     → Devise auth, polymorphic profileable
    student_profile.rb          → CV, skills, commitment score
    company_profile.rb          → Offers, response metrics, reputation
    university_profile.rb       → Coordinator access
    submission.rb               → Application state machine
    offer.rb                    → Internship postings with missions
    internship_agreement.rb     → Convention de Stage signing flow
    commitment_event.rb         → Audit log for score changes
    review.rb                   → Post-internship reviews
  jobs/
    verify_submission_job.rb    → Git repo verification via clone
    reputation_tracker_job.rb   → Daily ghosting penalty sweep
    resolve_expired_submissions_job.rb
config/
  recurring.yml     → Solid Queue recurring task schedule
  queue.yml         → Solid Queue worker configuration
  storage.yml       → Active Storage services (local/S3)
db/
  migrate/          → 24 migrations
  schema.rb         → Current DB schema
```

---

## Deployment

StageUp deploys via **Kamal** to any Docker-capable server.

```bash
# First deploy
kamal setup
kamal deploy

# Subsequent deploys
kamal deploy

# Run migrations on production
kamal app exec 'rails db:migrate'

# Check logs
kamal app logs
```

Production requires:
- A Linux server with Docker installed
- A PostgreSQL database (managed or self-hosted)
- An AWS S3 bucket for file storage
- An SMTP provider (Postmark, SendGrid, etc.)

---

## Security

- All passwords have a minimum length of **12 characters**
- Accounts are **locked after 10 failed login attempts** and unlocked via email
- Sessions **expire after 30 minutes** of inactivity
- All file uploads verify the PDF magic bytes before accepting (prevents disguised executables)
- Git repo URLs are validated against an allowlist of trusted hosts (GitHub, GitLab, Bitbucket) before cloning
- Rate limiting on signup, login, and password reset endpoints via Rack::Attack
- HTTPS enforced in production with HSTS headers
- Full suite of security headers (X-Frame-Options, X-Content-Type-Options, Referrer-Policy, Permissions-Policy)
- Brakeman static analysis runs in CI on every push

---

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Write tests for your changes
4. Run the full test suite: `rails test`
5. Run the linter: `bin/rubocop`
6. Open a pull request

All PRs are automatically scanned with Brakeman (security), RuboCop (style), and the full test suite via GitHub Actions.

---

## License

This project is proprietary. All rights reserved.

---

<div align="center">
Built with ❤️ in Tunisia · <a href="mailto:hello@stageup.tn">hello@stageup.tn</a>
</div>

