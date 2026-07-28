# 🎨 StageUp Frontend & Visual Design System Reference

This document is the visual source of truth for StageUp, enforcing a premium Vercel/Linear cinematic dark-mode aesthetic.

---

## 🎨 1. Core Visual Tokens (`:root`)

All front-end views must use semantic CSS tokens instead of hardcoded hex values:

```css
:root {
  --bg-primary: #07080A;          /* Deep space main background */
  --bg-secondary: #0F1015;        /* Cards, panels, containers */
  --bg-tertiary: #17181F;         /* Dialogs, dropdowns, popovers */
  
  --text-primary: #F4F4F6;        /* High-contrast silver white */
  --text-secondary: #9FA3AF;      /* Zinc gray body text */
  --text-muted: #626773;          /* Subtle sub-labels */
  
  --primary: #C2410C;             /* Terracotta primary accent */
  --primary-hover: #6366F1;
  --primary-light: rgba(99, 102, 241, 0.08);
  
  --accent: #FFFFFF;              /* Solid white CTA accent */
  --accent-hover: #E4E4E7;
  
  --success: #10B981;             /* Emerald green for completions */
  --danger: #EF4444;              /* Rose red for penalties */
  --warning: #F59E0B;             /* Amber for pending/started states */
  
  --border-color: rgba(255, 255, 255, 0.08); /* 1px hairline gray border */
  --border-focus: rgba(99, 102, 241, 0.4);   /* Indigo focus ring */
  
  --radius-sm: 8px;
  --radius-md: 12px;
  --radius-lg: 16px;
  
  --shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.3);
  --shadow-md: 0 4px 20px rgba(0, 0, 0, 0.5);
  --shadow-lg: 0 10px 30px rgba(0, 0, 0, 0.6);
  --transition: all 0.25s cubic-bezier(0.16, 1, 0.3, 1);
}
```

---

## 🏷️ 2. Badge Semantics Lookup Matrix

Badges must follow semantic color assignments—never assign ad-hoc colors per component:

| Meaning / Type | Visual Style | CSS / Tailored Class | Example Label |
|---|---|---|---|
| **Stage Type** (Classification) | Gray outline, no fill | `border: 1px solid var(--border-color); color: var(--text-secondary); background: transparent;` | `PFA`, `PFE`, `Initiation` |
| **Requires Action** | Indigo fill & border | `background: rgba(99, 102, 241, 0.06); border: 1px solid rgba(99, 102, 241, 0.2); color: #818CF8;` | `Mission Attached` |
| **Simple / Standard** | Gray muted | `background: rgba(255, 255, 255, 0.02); border: 1px solid var(--border-color); color: var(--text-secondary);` | `CV Only` |
| **Positive Status** | Success green | `background: rgba(16, 185, 129, 0.06); border: 1px solid rgba(16, 185, 129, 0.2); color: #34D399;` | `Completed`, `Verified` |
| **Negative Status** | Danger red | `background: rgba(239, 68, 68, 0.06); border: 1px solid rgba(239, 68, 68, 0.2); color: #F87171;` | `Expired`, `Rejected` |
| **Grace Period** | Amber / Yellow | `background: rgba(245, 158, 11, 0.06); border: 1px solid rgba(245, 158, 11, 0.2); color: #FBBF24;` | `New Recruiter` |

---

## 💎 3. Key Component Specifications

### 3.1 Commitment Score Pill (`.score-pill`)
- Structure:
  ```html
  <div class="score-pill">
    <span class="dot dot-success"></span>
    <strong>95</strong>
    <span class="score-label">Commitment</span>
  </div>
  ```
- Dot colors: Green (`#10B981`) for score >= 90, Orange (`#F59E0B`) for 70..89, Red (`#EF4444`) for < 70.

### 3.2 Icon Guidelines (Lucide CDN)
- **Emojis are banned** as structural icons or action elements (`🎓`, `💼`, `⚡`).
- Use **Lucide SVG Icons**: `<i data-lucide="shield-check" style="width: 18px; height: 18px;"></i>`.
- Default icon color: Muted `var(--text-secondary)`.

---

## 🚫 4. Anti-"AI-Generated UI" Self-Checklist

Before finalizing UI code, verify against these common AI design mistakes:

| AI Failure Pattern | What to Avoid | Correct Practice |
|---|---|---|
| **Generic Centered Hero** | Simple centered column with title + description + buttons. | Use asymmetric grid layouts or interactive product mockups. |
| **Bootstrap Spacing** | Uniform vertical gaps everywhere (`margin-bottom: 20px`). | Use strict 8px scale (`32px`, `48px`, `64px` section gaps). |
| **Overused Gradient Blobs** | Bright neon circles that obscure copy. | Use dark muted background glows (`rgba(99, 102, 241, 0.06)`). |
| **Emoji Spam** | Using emojis for navigation or status indicators. | Use clean Lucide icons paired with text labels. |
| **Nested Border Clutter** | Putting card boxes inside card boxes. | Use negative space and hairline dividers (`1px solid var(--border-color)`). |
