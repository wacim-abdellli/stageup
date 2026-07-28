---
name: stageup-design
description: "Visual style-guide and design tokens for StageUp. Enforces a premium Vercel/Linear dark-mode aesthetic. Use this skill whenever editing, styling, or creating UI pages, templates, stylesheets, or component views."
---

# StageUp Premium Design System

This document serves as the **Visual Source of Truth** for StageUp. All current and future front-end implementation tasks must strictly follow these aesthetic guidelines to ensure visual consistency, premium quality, and modern feel.

---

## 1. Core Visual Pillars

1. **Cinematic Dark Palette:** We avoid oversaturated dark-blues or purples. Backgrounds use deep neutral charcoal/black tints.
2. **Hairline Separators:** Replace solid colored borders with semi-transparent grey hairlines (`1px solid rgba(255, 255, 255, 0.08)`).
3. **Edge Specular Highlights:** Cards and buttons use subtle inner 3D highlights (`inset 0 1px 0 rgba(255, 255, 255, 0.05)`) to feel tactile.
4. **High-Contrast Typography & CTAs:** Primary CTAs use solid white backgrounds with dark text to stand out cleanly on dark-mode fields.

---

## 2. Design Tokens & CSS Variables

Ensure these variable tokens are declared in `:root` and used across all stylesheet classes:

```css
:root {
  --bg-primary: #07080A;          /* Deep space background */
  --bg-secondary: #0F1015;        /* Cards and block containers */
  --bg-tertiary: #17181F;         /* Dialogs, panels, and drop-downs */
  
  --text-primary: #F4F4F6;        /* Primary silver-white headers */
  --text-secondary: #9FA3AF;      /* Body copy / zinc grey */
  --text-muted: #626773;          /* Secondary descriptions */
  
  --primary: #C2410C;             /* Terracotta brand accent */
  --primary-hover: #EA580C;
  --primary-light: rgba(194, 65, 12, 0.08);
  
  --accent: #FFFFFF;              /* Solid white CTA accent */
  --accent-hover: #E4E4E7;
  
  --success: #10B981;             /* Emerald green for positive completion alerts */
  --danger: #EF4444;              /* Rose red for penalties or deletions */
  --warning: #F59E0B;             /* Amber for started states */
  
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

## 3. Typography, Spacing, & Layout Rules

### 3.1 Typography Scale
* **Header Font Family:** `'Outfit'`, sans-serif. Always use tight tracking (`letter-spacing: -0.02em`) for bold headers to feel professional.
* **Body Font Family:** `'Inter'`, sans-serif (clean, geometric, system-like).
* **Sizes & Hierarchy:**
  * **Hero Title:** `clamp(36px, 5vw, 64px)` (font-weight: 800, line-height: 1.1).
  * **H1 (Page titles):** `32px` (font-weight: 700, line-height: 1.2).
  * **H2 (Section titles):** `22px` (font-weight: 600, line-height: 1.3).
  * **H3 (Card headers):** `16px` (font-weight: 600, line-height: 1.4).
  * **Body (Regular text):** `14px` or `15px` (font-weight: 400, line-height: 1.5).
  * **Muted / Labels:** `12px` (font-weight: 500, letter-spacing: 0.05em, text-transform: uppercase).

### 3.2 Spacing Scale
Never use arbitrary padding or margins. Stick strictly to this 8px increments scale:
* `4px` (`--space-3xs`): Tiny adjustments, labels padding, elements gaps.
* `8px` (`--space-2xs`): Tight spacing inside components.
* `12px` (`--space-xs`): Standard badge/button padding.
* `16px` (`--space-sm`): Default card inner elements spacing.
* `24px` (`--space-md`): Standard card padding, grid gaps.
* `32px` (`--space-lg`): Dashboard section spacing.
* `48px` (`--space-xl`): Massive page margins / hero section spacing.
* `64px` (`--space-2xl`): Outer wrapper spacing.

### 3.3 Responsive Breakpoints
Follow mobile-first style queries. Use these standardized screen widths:
* **Mobile / Base viewport:** `< 640px` (sm)
* **Tablet viewports:** `640px` to `1024px` (md)
* **Desktop viewports:** `1024px` to `1280px` (lg)
* **Wide monitors:** `> 1280px` (xl)

---

## 4. UI Component Specifications

### 4.1 Icon Library (Lucide CDN)
* Emojis (`🎓`, `💼`, `⚡`) are strictly banned as primary navigation or structural action graphics.
* Use **Lucide Icons** loaded via CDN. Render icons using:
  `<i data-lucide="icon-name" class="icon-class" style="width: 18px; height: 18px;"></i>`
* Keep icon colors muted (`var(--text-secondary)` or `var(--text-muted)`) and only highlight on parent hover.

### 4.2 Buttons
* **Primary / Accent Button (`.btn-accent` or `.btn-primary`):**
  * Solid white background (`#FFFFFF`), dark text (`#09090B`), bold weight.
  * Thin border: `1px solid rgba(255, 255, 255, 0.15)`.
  * Subtle white shadow: `box-shadow: 0 4px 12px rgba(255, 255, 255, 0.08)`.
* **Secondary Button (`.btn-secondary`):**
  * Semi-transparent grey outline: `rgba(255, 255, 255, 0.02)`.
  * Border: `1px solid var(--border-color)`.
  * Hover: `rgba(255, 255, 255, 0.06)`, border-color changes to `rgba(255, 255, 255, 0.15)`.

### 4.3 Cards & Panels (`.profile-card`, `.bento-card`)
* Background: `rgba(255, 255, 255, 0.02)` or `var(--bg-secondary)`.
* Border: `1px solid var(--border-color)`.
* Edge highlight: `box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.05)`.
* Hover state: `border-color: rgba(255, 255, 255, 0.18)` and `background-color: rgba(255, 255, 255, 0.04)`.
* **NO** colored outlines or neon gradients on the cards.

### 4.4 Commitment Score & Rating Displays
* **Commitment Score Pill (`.score-pill`):**
  * Background: `rgba(99, 102, 241, 0.06)`, border: `1px solid rgba(99, 102, 241, 0.15)`, padding: `4px 10px`, border-radius: `9999px`, display: `inline-flex`, align-items: `center`, gap: `6px`.
  * Status indicator dot: Left side, green `#10B981` (score >= 90), orange `#F59E0B` (70 <= score < 90), red `#EF4444` (score < 70).
  * Structure: `<div class="score-pill"><span class="dot dot-success"></span><strong>95</strong><span class="score-label">Commitment</span></div>`
* **Rating Display (`.rating-display`):**
  * Muted gold star icon: Lucide `star` (`#F59E0B`), bold decimal rating, counts in parenthesis.
  * Structure: `<div class="rating-display"><i data-lucide="star" style="fill: #F59E0B; stroke: #F59E0B;"></i><strong>4.8</strong><span class="rating-count">(12 reviews)</span></div>`

### 4.5 Unified Status Badge System
Apply the following CSS classes and styles for consistent states:
* `.badge-status`: Base size `11px`, weight `600`, padding `2px 8px`, border-radius `9999px`, inline-flex, border: `1px solid`.
* **Pending (`pending` / `.badge-pending`):**
  * Style: `background-color: rgba(245, 158, 11, 0.06); border-color: rgba(245, 158, 11, 0.2); color: #F59E0B;`
* **In Progress (`started` / `.badge-progress`):**
  * Style: `background-color: rgba(99, 102, 241, 0.06); border-color: rgba(99, 102, 241, 0.2); color: #818CF8;`
* **Accepted / Active (`accepted` / `.badge-accepted`):**
  * Style: `background-color: rgba(59, 130, 246, 0.06); border-color: rgba(59, 130, 246, 0.2); color: #60A5FA;`
* **Completed (`completed` / `.badge-completed`):**
  * Style: `background-color: rgba(16, 185, 129, 0.06); border-color: rgba(16, 185, 129, 0.2); color: #34D399;`
* **Rejected (`rejected` / `.badge-rejected`):**
  * Style: `background-color: rgba(239, 68, 68, 0.06); border-color: rgba(239, 68, 68, 0.2); color: #F87171;`

### 4.6 'Grace Period / New Recruiter' Component
For companies with < 3 completed contracts:
* Class: `.badge-grace` (background: `rgba(255, 255, 255, 0.02)`, border: `1px solid var(--border-color)`, border-radius: `9999px`, color: `var(--text-secondary)`, display: `inline-flex`, align-items: `center`, padding: `4px 10px`, gap: `6px`, font-size: `12px`).
* Icon: Lucide `sparkles` in soft blue (`#60A5FA`).
* Text: `New Recruiter (Grace Period)`.
* Tooltip/Tooltip container: Displays: *"Commitment score is protected during your first 3 internships to help you get established."*

---

## 5. Anti-"AI-Generated UI" Self-Checking Checklist

To avoid generic-looking layouts, the agent must check all modifications against the following "AI tells" before presenting work to the user:

| AI Tell | What to Avoid | Correct Premium Practice |
|---------|---------------|--------------------------|
| **Generic Centered Hero** | Simple centered column box with title + description + two buttons. | Use asymmetric grid layouts, offset columns, or lead with real interactive product mockups. |
| **Bootstrap-y Spacing** | Standard repeating vertical gaps (e.g. all sections separated by `margin-bottom: 20px`). | Use varied depth scales (large margins between sections, tight grouped elements). Let layout breathe. |
| **Overused Gradient Blobs** | Bright purple/pink neon circles competing with copy readability. | Keep background light sources dark and muted (`rgba(99, 102, 241, 0.06)`). Use hairline borders for structure. |
| **Emoji Spam** | Emojis acting as indicators or structural navigation elements. | Use clean vector SVGs or Lucide icons. |
| **Boxed Everything** | Nesting card containers within card containers, creating double-border clutter. | Use negative space, vertical divider lines, or varying background tones to divide content instead of border boxes. |

---

## 6. Advanced Brand Rules

### 6.1 Icon Rules
* **Semantic Uniqueness:** One icon = one concept, platform-wide. Before adding any icon, check: is this icon already used for something else? If yes, pick a different one.
* **Muted Visuals:** Icons are muted by default, never decorative color: use `color: var(--text-secondary)` (gray) unless the icon is an explicit status indicator (success/danger/warning).
* **Abstract Concepts:** No literal-object icons for abstract concepts. Emojis or icons like trophy, lightning, or graduation-cap are clip-art metaphors. Prefer structural icons (Lucide: `check-circle`, `git-commit`, `shield-check`) that feel like product UI, not a slide deck.
* **Icon Labels:** Icons never carry meaning alone. Every icon pairs with a text label — never icon-only unless it's a universally understood control (close, menu).

### 6.2 Badge Color Semantics Table
A badge's color is looked up from this table by meaning, never assigned ad hoc per-component:

| Meaning | Color Scheme | CSS / Tailored Class | Example |
|---|---|---|---|
| **Stage type** (neutral classification) | Gray outline, no fill | `border: 1px solid var(--border-color); color: var(--text-secondary); background: transparent;` | PFA, PFE, Initiation |
| **Requires action / extra step** | Indigo (brand primary) | `background: rgba(99, 102, 241, 0.06); border: 1px solid rgba(99, 102, 241, 0.2); color: #818CF8;` | Mission Attached |
| **Simple / no extra step** | Gray, muted | `background: rgba(255, 255, 255, 0.02); border: 1px solid var(--border-color); color: var(--text-secondary);` | CV Only |
| **Positive status** | Success green | `background: rgba(16, 185, 129, 0.06); border: 1px solid rgba(16, 185, 129, 0.2); color: #34D399;` | Completed, Verified |
| **Negative/warning status** | Danger coral/red | `background: rgba(239, 68, 68, 0.06); border: 1px solid rgba(239, 68, 68, 0.2); color: #F87171;` | Expired, Rejected |
| **Grace period / provisional** | Amber/Yellow | `background: rgba(245, 158, 11, 0.06); border: 1px solid rgba(245, 158, 11, 0.2); color: #FBBF24;` | Establishing Reputation |

### 6.3 Spacing Rules
* **Gaps:** All vertical section gaps must be one of: `32px` / `48px` / `64px` — nothing in between, nothing eyeballed.
* **Visual Anchor:** Every section boundary needs either a hairline divider or a background shift — never just empty space with no visual anchor.

---

## 7. Pre-Ship Checklist
Before presenting ANY UI work to the user, run through this checklist and report the findings explicitly:
1. **[ ] Icon Duplicate Check:** Does any icon on this page duplicate an icon used elsewhere for a different concept?
2. **[ ] Badge Semantics Check:** Does every badge's color match the semantics table above?
3. **[ ] 8px Spacing Check:** Is every spacing value on the 8px scale?
4. **[ ] Duplicate Info Check:** Are there two elements on the page showing the same information twice? (e.g. location vs work mode rendering duplicate text).
5. **[ ] Listing Features Check:** If this is a listing/index page — does it have search/filter, or is that explicitly deferred?
