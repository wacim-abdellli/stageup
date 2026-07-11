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
  
  --primary: #4F46E5;             /* Indigo accent (used sparingly) */
  --primary-hover: #6366F1;
  --primary-light: rgba(99, 102, 241, 0.08);
  
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

## 3. UI Component Specifications

### 3.1 Buttons
* **Primary / Accent Button (`.btn-accent` or `.btn-primary`):**
  * Solid white background (`#FFFFFF`), dark text (`#09090B`), bold weight.
  * Thin border: `1px solid rgba(255, 255, 255, 0.15)`.
  * Subtle white shadow: `box-shadow: 0 4px 12px rgba(255, 255, 255, 0.08)`.
* **Secondary Button (`.btn-secondary`):**
  * Semi-transparent grey outline: `rgba(255, 255, 255, 0.02)`.
  * Border: `1px solid var(--border-color)`.
  * Hover: `rgba(255, 255, 255, 0.06)`, border-color changes to `rgba(255, 255, 255, 0.15)`.

### 3.2 Cards & Panels (`.profile-card`, `.bento-card`)
* Background: `rgba(255, 255, 255, 0.02)` or `var(--bg-secondary)`.
* Border: `1px solid var(--border-color)`.
* Edge highlight: `box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.05)`.
* Hover state: `border-color: rgba(255, 255, 255, 0.18)` and `background-color: rgba(255, 255, 255, 0.04)`.
* **NO** colored outlines or neon gradients on the cards.

### 3.3 Form Inputs (`.form-control`)
* Background: `var(--bg-primary)` (darker than container cards).
* Border: `1px solid var(--border-color)`.
* Focused state: border-color transitions to `var(--primary)` with a subtle indigo outer focus ring.

---

## 4. Layout & Grid Structures

### 4.1 Ambient Light Effect
* Page headers or landing sections should use a very subtle radial gradient glow top highlight:
  `background: radial-gradient(circle at top, rgba(99, 102, 241, 0.06) 0%, transparent 65%);`
* Maintain transparency; do not combine with bright solid colors.

### 4.2 Bento Grid Layout
* Grid displays should use `display: grid` with multi-column structures on desktop (max-w 1000px) scaling down to 1-column on mobile viewports.
* Gaps should be unified to `20px`.
* Individual bento cells should align left, containing medium border radii (`--radius-lg: 16px`) and clear icons.

---

## 5. Verification Checklist

Whenever styling is updated, check:
- [ ] No emojis are used as primary navigation or action icons (use SVG/Lucide).
- [ ] Saturated purple background `#0F0F23` is completely absent.
- [ ] Contrast ratios between text and background surfaces meet a minimum of 4.5:1.
- [ ] Borders are thin (1px) and translucent rather than bright/thick.
- [ ] Buttons use smooth transitions (`all 0.25s cubic-bezier(0.16, 1, 0.3, 1)`).
