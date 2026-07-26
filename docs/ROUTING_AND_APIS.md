# 🛣️ StageUp Routing & Endpoints Reference

This document maps all Rails application routes, Devise onboarding flows, member endpoints, and access control policies.

---

## 🚪 1. Authentication & Onboarding Routes

Devise registration is customized to support role selection before creating account profiles:

| HTTP Verb | Path | Controller#Action | Access / Description |
|-----------|------|-------------------|----------------------|
| `GET` | `/signup` | `users/registrations#select_role` | Public role selector (Student / Company / University) |
| `GET` | `/signup/student` | `users/registrations#new_student` | Student registration form |
| `POST` | `/signup/student` | `users/registrations#create_student` | Creates `User` + `StudentProfile` |
| `GET` | `/signup/company` | `users/registrations#new_company` | Company registration form |
| `POST` | `/signup/company` | `users/registrations#create_company` | Creates `User` + `CompanyProfile` |
| `GET` | `/signup/university` | `users/registrations#new_university` | University Coordinator registration form |
| `POST` | `/signup/university` | `users/registrations#create_university` | Creates `User` + `UniversityProfile` |
| `GET` | `/users/sign_in` | `devise/sessions#new` | Standard Devise login |
| `POST` | `/users/sign_in` | `devise/sessions#create` | Standard Devise session creation |
| `DELETE` | `/users/sign_out` | `devise/sessions#destroy` | Session destruction |

---

## 📊 2. Dashboards & Core Views

| HTTP Verb | Path | Controller#Action | Access / Description |
|-----------|------|-------------------|----------------------|
| `GET` | `/` | `home#index` | Public home page / offer discovery |
| `GET` | `/reputation_events` | `home#reputation_events` | Public reputation score audit feed |
| `GET` | `/dashboard` | `dashboards#show` | Role-specific dashboard (Student / Company / University) |
| `PATCH` | `/dashboard/update_cv` | `dashboards#update_cv` | Student CV upload endpoint |

---

## 💼 3. Offers Management (`/offers`)

| HTTP Verb | Path | Controller#Action | Access / Description |
|-----------|------|-------------------|----------------------|
| `GET` | `/offers` | `offers#index` | Public search & filter offers |
| `GET` | `/offers/new` | `offers#new` | Company create offer form |
| `POST` | `/offers` | `offers#create` | Company create offer + optional mission |
| `GET` | `/offers/:id` | `offers#show` | Offer details page |
| `GET` | `/offers/:id/edit` | `offers#edit` | Company edit offer form |
| `PATCH/PUT` | `/offers/:id` | `offers#update` | Company update offer details |
| `DELETE` | `/offers/:id` | `offers#destroy` | Company delete offer |
| `POST` | `/offers/:id/publish` | `offers#publish` | Publish drafted offer |

---

## 📝 4. Application Submissions & Lifecycle (`/submissions`)

| HTTP Verb | Path | Controller#Action | Access / Description |
|-----------|------|-------------------|----------------------|
| `POST` | `/submissions` | `submissions#create` | Student applies / starts proof mission (48h timer) |
| `GET` | `/submissions/:id/edit` | `submissions#edit` | Student mission submission form |
| `PATCH/PUT` | `/submissions/:id` | `submissions#update` | Student uploads GitHub link / proof solution |
| `POST` | `/submissions/:id/accept` | `submissions#accept` | Company accepts application |
| `POST` | `/submissions/:id/reject` | `submissions#reject` | Company rejects application |
| `POST` | `/submissions/:id/confirm_completion` | `submissions#confirm_completion` | Student/Company confirms internship end |
| `POST` | `/submissions/:id/abandon` | `submissions#abandon` | Student quits active internship (-25 score penalty) |
| `POST` | `/submissions/:id/cancel` | `submissions#cancel` | Student cancels application before response |

---

## 📄 5. Convention de Stage (Agreements) & Reviews

### Nested Agreements (`/submissions/:submission_id/internship_agreements`)
| HTTP Verb | Path | Controller#Action | Access / Description |
|-----------|------|-------------------|----------------------|
| `GET` | `.../internship_agreements/new` | `internship_agreements#new` | Generate agreement form |
| `POST` | `.../internship_agreements` | `internship_agreements#create` | Create 3-party agreement |
| `GET` | `.../internship_agreements/:id` | `internship_agreements#show` | View agreement & signature state |
| `POST` | `.../internship_agreements/:id/sign` | `internship_agreements#sign` | Digital signature submission |
| `POST` | `.../internship_agreements/:id/decline` | `internship_agreements#decline` | Decline agreement terms |

### Nested Reviews (`/submissions/:submission_id/reviews`)
| HTTP Verb | Path | Controller#Action | Access / Description |
|-----------|------|-------------------|----------------------|
| `GET` | `.../reviews/new` | `reviews#new` | Form to leave rating & review |
| `POST` | `.../reviews` | `reviews#create` | Submit review (1-5 stars) |

---

## 🛡️ 6. Admin Namespace (`/admin`)

Requires `user.admin == true`:

| HTTP Verb | Path | Controller#Action | Access / Description |
|-----------|------|-------------------|----------------------|
| `GET` | `/admin/dashboard` | `admin/dashboards#index` | Admin control panel |
| `POST` | `/admin/company_profiles/:id/verify` | `admin/company_profiles#verify` | Set company profile `verified: true` |
| `POST` | `/admin/company_profiles/:id/unverify` | `admin/company_profiles#unverify` | Revoke company verification |
| `POST` | `/admin/university_profiles/:id/approve` | `admin/university_profiles#approve` | Approve university coordinator profile |
| `POST` | `/admin/university_profiles/:id/reject` | `admin/university_profiles#reject` | Reject university coordinator profile |
