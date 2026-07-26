# 🤖 StageUp — AI Agent Master Reference & Context Entrypoint

> **IMPORTANT**: This document is the primary entrypoint for all AI Agents (Auditor, Architecture, and Implementation agents) working on StageUp. Read this file and linked reference documents before making changes or analyzing code.

---

## 🚀 App Overview

**StageUp** is Tunisia's first verified internship platform built to end internship ghosting using three core mechanisms:
1. **Proof-of-Work Missions**: 48-hour practical tasks attached to internship offers before application acceptance.
2. **Commitment Scoring System**: Transparent reputation score (default 100/100) tracking student and company reliability.
3. **Official Convention de Stage**: 3-party digital signature agreement (Student + Company + University Coordinator).

---

## 📁 Technical Subsystem Cheat Sheets

Do not spend turns re-exploring the codebase to discover routes, schemas, or design system tokens. Refer to these pre-digested documents:

- 🏛️ **[docs/ARCHITECTURE.md](file:///c:/Users/pc/Desktop/stageup/docs/ARCHITECTURE.md)**: Domain models, state machines, Commitment Score math, background jobs (Solid Queue).
- 🛣️ **[docs/ROUTING_AND_APIS.md](file:///c:/Users/pc/Desktop/stageup/docs/ROUTING_AND_APIS.md)**: All Rails routes, Devise onboarding flows, role authorizations, controller actions.
- 🗄️ **[docs/DATABASE_SCHEMA.md](file:///c:/Users/pc/Desktop/stageup/docs/DATABASE_SCHEMA.md)**: Database tables, polymorphic relationships, foreign keys, and indexes.
- 🎨 **[docs/FRONTEND_DESIGN_SYSTEM.md](file:///c:/Users/pc/Desktop/stageup/docs/FRONTEND_DESIGN_SYSTEM.md)**: Design tokens (`#07080A`), Vercel/Linear dark aesthetic rules, component specs (`.score-pill`, `.badge-status`), Lucide icon guidelines.

---

## 📜 Core Agent Execution Rules (AGENTS.md Enforced)

1. **Git Commit Discipline**: Always run `git add`, `git commit -m "..."`, and `git push` after completing each UI/UX redesign task or bug fix.
2. **Vercel/Linear Aesthetic**: Enforce a high-contrast cinematic dark mode theme (`--bg-primary: #07080A`).
3. **No Inline CSS**: Never style HTML templates using raw `style="..."` attributes (except dynamic values). Always use semantic CSS classes or variables.
4. **Use Semantic Tokens**: Prefer CSS variable tokens (e.g. `var(--bg-primary)`, `var(--border-color)`) over hardcoded hex values.

---

## 🧪 Verification & Testing Quick Commands

```bash
# Run entire test suite
rails test

# Run specific controller or model test
rails test test/controllers/submissions_controller_test.rb

# Run system tests (requires Chrome)
rails test:system

# Code style linting
bin/rubocop

# Security analysis
bin/brakeman
```
