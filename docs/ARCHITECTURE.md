# 🏛️ StageUp Architecture & Domain Reference

This document details the core architecture, domain models, state machine workflows, scoring logic, and background jobs of StageUp.

---

## 👥 1. User Roles & Polymorphic Profile System

Authentication is handled via **Devise** on the `User` model, which uses a **polymorphic association** to attach role-specific profile data:

```
                  ┌──────────────────────┐
                  │      User (Devise)   │
                  │ ──────────────────── │
                  │ email                │
                  │ encrypted_password   │
                  │ admin (boolean)      │
                  │ profileable (poly)   │
                  └──────────┬───────────┘
                             │
       ┌─────────────────────┼─────────────────────┐
       ▼                     ▼                     ▼
┌───────────────┐     ┌────────────────┐    ┌───────────────────┐
│StudentProfile │     │ CompanyProfile │    │UniversityProfile │
├───────────────┤     ├────────────────┤    ├───────────────────┤
│first_name     │     │name            │    │department         │
│last_name      │     │description     │    │approved (bool)    │
│commitment_score│    │commitment_score│    │university_id      │
│university_id  │     │verified (bool) │    └───────────────────┘
└───────────────┘     └────────────────┘
```

### Roles Matrix
- **Student**: Has `StudentProfile`. Browses offers, completes 48-hour proof missions, tracks applications, signs digital agreements, and leaves reviews.
- **Company**: Has `CompanyProfile`. Creates internship offers with optional missions, evaluates candidate submissions, signs agreements, and manages internships.
- **University Coordinator**: Has `UniversityProfile`. Oversees students affiliated with their university, approves student agreements via 3rd digital signature.
- **Admin**: Has `admin: true` on `User`. Verifies company profiles and approves university coordinator registrations.

---

## 🔄 2. State Machine Workflows

### 2.1 Submission (Application) Lifecycle
Submissions track an application's progress from initial mission start to final internship completion:

```
 [ started ] ──(Submit Code/URL within 48h)──► [ submitted ]
      │                                             │
 (48h Timeout)                                ┌─────┴─────┐
      ▼                                       ▼           ▼
  [ expired ]                            [ accepted ] [ rejected ]
                                              │
                                 ┌────────────┴────────────┐
                                 ▼                         ▼
                           [ completed ]             [ abandoned ]
```

- **`started`**: Student clicks "Apply" on an offer with a mission. Starts a 48-hour timer.
- **`submitted`**: Student uploads solution URL / GitHub link. Triggers `VerifySubmissionJob`.
- **`accepted`**: Company approves submission. Allows generation of `InternshipAgreement`.
- **`rejected`**: Company rejects submission.
- **`completed`**: Both student & company confirm completion (or 7-day auto-confirm window expires).
- **`abandoned`**: Student quits active internship (triggers -25 commitment score penalty).

### 2.2 Convention de Stage (Internship Agreement) Signature Flow
A formal 3-party contract created upon submission acceptance:

```
[ pending_signatures ]
  ├── 1. Student signs  ──► student_signed_at
  ├── 2. Company signs  ──► company_signed_at
  └── 3. University signs─► university_signed_at
       │
       ▼ (All 3 signatures present)
   [ signed ]
```
*Note: If any party rejects the terms, status moves to `rejected` with a `rejection_reason`.*

---

## ⚡ 3. Commitment Scoring System

Every student and company starts with a default score of **`100.0`**. Score updates trigger audit log entries in the `commitment_events` table.

### Score Delta Matrix
| Event Trigger | Target Role | Delta | Description |
|---------------|-------------|-------|-------------|
| **Timely Response** | Company | `+1.0` | Company responds to application in < 14 days |
| **Late Response** | Company | `-5.0` | Company responds after 14 days |
| **Ghosting Penalty** | Company | `-15.0` | Company fails to respond in 14+ days (auto-swept daily) |
| **Internship Completed** | Student / Company | `+15.0` | Successfully completes confirmed internship |
| **Internship Abandoned** | Student | `-25.0` | Student quits after signing agreement |
| **Mission Timeout (2nd+)** | Student | `-10.0` | Student lets a started mission expire without submitting |

### Recruiter Grace Period
Companies with fewer than 3 completed internships display a **"New Recruiter (Grace Period)"** badge (`.badge-grace`), protecting their public reputation score while establishing their account.

---

## ⚙️ 4. Background Jobs (Solid Queue)

StageUp uses **Solid Queue** for background execution. Configured in `config/recurring.yml`:

1. **`VerifySubmissionJob`**:
   - Triggered when a student submits a GitHub URL.
   - Clones repository in isolated sandbox, checks for required files, updates `auto_verification_status` to `passed`/`failed`.

2. **`ReputationTrackerJob`** *(Daily at 00:00)*:
   - Scans all `submitted` applications pending > 14 days without company action.
   - Applies `-15.0` penalty to the company's commitment score and logs a `CommitmentEvent`.

3. **`ResolveExpiredSubmissionsJob`** *(Hourly)*:
   - Expires unsubmitted proof missions after 48 hours.
   - Auto-completes internships where one party confirmed completion > 7 days ago.
