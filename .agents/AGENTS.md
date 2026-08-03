# Workspace Agent Rules & Guidelines

## 📌 Core Operational Directives

1. **Git Commit Directive:**
   - Commit and push to git (`git add .`, `git commit -m "..."`, `git push`) after completing each UI/UX redesign step, bug fix, or feature enhancement task.

2. **Visual Consistency & Aesthetic Tokens:**
   - Adhere strictly to the **Vercel / Linear dark-mode aesthetic**.
   - Avoid styling views using raw inline HTML styles (e.g. `style="..."`).
   - Prefer semantic CSS variable tokens (`var(--bg-primary)`, `var(--bg-secondary)`, `var(--text-primary)`, `var(--border-color)`) over hardcoded hex or RGB colors.
   - Maintain support for both **Dark Mode** (`:root`) and **Light Mode** (`[data-theme="light"]`) without visual contrast collapse.

3. **Mobile Responsiveness Standards:**
   - Ensure all layouts, navigation elements, filter sidebars, and cards adapt gracefully down to mobile viewports (360px – 440px).
   - Enforce single-column vertical stacking for grid components (`grid-template-columns: 1fr !important`) on screens `< 900px`.
   - Prevent header clutter by hiding secondary desktop controls from the top header bar on mobile (`< 768px`) and embedding them inside the full-width mobile navigation drawer.
   - Ensure all touch targets maintain a minimum touch area (`44px` height).

4. **Safety & Test Integrity:**
   - Maintain 100% clean test execution (`rails test`). Never comment out or disable failing assertions.
   - Ensure concurrency safety using row locks (`with_lock`) for score recalculations, state machine transitions, and agreement signatures.
   - Scope all controller resource lookups to the current authenticated profile (`current_user.profileable`).
