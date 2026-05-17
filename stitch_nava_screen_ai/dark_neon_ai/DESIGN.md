---
name: Dark Neon AI
colors:
  surface: '#0e141a'
  surface-dim: '#0e141a'
  surface-bright: '#333a40'
  surface-container-lowest: '#080f14'
  surface-container-low: '#161c22'
  surface-container: '#1a2026'
  surface-container-high: '#242b31'
  surface-container-highest: '#2f353c'
  on-surface: '#dde3eb'
  on-surface-variant: '#d6c0d3'
  inverse-surface: '#dde3eb'
  inverse-on-surface: '#2b3137'
  outline: '#9f8b9d'
  outline-variant: '#524251'
  surface-tint: '#fbabff'
  primary: '#fbabff'
  on-primary: '#580065'
  primary-container: '#e14ef6'
  on-primary-container: '#4d0059'
  inverse-primary: '#a200ba'
  secondary: '#d0bcff'
  on-secondary: '#3c0091'
  secondary-container: '#571bc1'
  on-secondary-container: '#c4abff'
  tertiary: '#cebdff'
  on-tertiary: '#381385'
  tertiary-container: '#9b7fed'
  on-tertiary-container: '#31057e'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#ffd6fd'
  primary-fixed-dim: '#fbabff'
  on-primary-fixed: '#36003e'
  on-primary-fixed-variant: '#7c008e'
  secondary-fixed: '#e9ddff'
  secondary-fixed-dim: '#d0bcff'
  on-secondary-fixed: '#23005c'
  on-secondary-fixed-variant: '#5516be'
  tertiary-fixed: '#e8ddff'
  tertiary-fixed-dim: '#cebdff'
  on-tertiary-fixed: '#21005e'
  on-tertiary-fixed-variant: '#4f319c'
  background: '#0e141a'
  on-background: '#dde3eb'
  surface-variant: '#2f353c'
typography:
  headline-xl:
    fontFamily: Inter
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 48px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  container-padding: 20px
  gutter: 16px
---

## Brand & Style

The design system is built for a futuristic, high-performance AI assistant. It utilizes a **Dark Neon** aesthetic that merges deep-space backgrounds with vibrant, bio-luminescent accents. The goal is to evoke a sense of intelligence, speed, and cutting-edge technology.

The interface leverages high-contrast gradients and subtle glows to guide the user's eye toward primary actions and AI-generated insights. The mood is immersive and sophisticated, prioritizing clarity amidst a rich, atmospheric environment.

## Colors

The palette is anchored by a deep midnight base (#0A0A14), ensuring that the neon primary gradients achieve maximum luminosity. 

- **Primary Gradient:** A transition from Pink (#D946EF) to Purple (#8B5CF6), used for high-priority actions, active states, and AI status indicators.
- **Surface Colors:** Cards utilize a slightly lighter purple-tinted black (#11091E) with a defined border (#2A1A4A) to maintain structure without breaking the dark immersion.
- **Functional Colors:** Standardized semantic colors for Success, Warning, and Error are adjusted for high visibility against dark backgrounds.

## Typography

The design system relies exclusively on **Inter** to provide a clean, technical, and highly legible experience. 

Headings are set in **Bold (700)** or **Semi-Bold (600)** to stand out against the dark background. Body text uses **Regular (400)** weight in #E2E8F0 to ensure high contrast and reduce eye strain. Labels and utility text use slightly increased letter spacing and uppercase styling where appropriate to maintain a systematic, "HUD" (Heads-Up Display) feel.

## Layout & Spacing

This design system follows a **fluid grid** model with a base unit of 4px. Layouts are built using a 12-column structure on desktop and a 4-column structure on mobile.

- **Margins:** A consistent 20px safe area is maintained on mobile devices.
- **Section Spacing:** Generous vertical padding (32px+) is used to separate content blocks, allowing the neon elements enough "room to breathe."
- **Alignment:** Content is generally center-aligned for hero AI interactions and left-aligned for data-heavy chat logs or settings.

## Elevation & Depth

Depth is established through **Tonal Layers** and **Glows** rather than traditional heavy shadows.

1.  **Base:** The #0A0A14 background.
2.  **Surface:** Cards and containers at #11091E with a 1px border (#2A1A4A).
3.  **Active Elevation:** Interactive elements may feature a subtle outer glow using the primary purple color (low opacity, 10-20px blur) to simulate light emission.
4.  **Overlays:** Modals and dropdowns use a slightly more opaque background or a subtle backdrop blur (10px) to separate themselves from the primary UI layer.

## Shapes

The shape language is modern and approachable, featuring generous corner radii. 

- **Cards & Large Containers:** A fixed 20px radius is used to create a "containerized" feel.
- **Buttons & Chips:** Use a pill-shaped radius (9999px) for a friendly, modern tech aesthetic.
- **Inputs:** Use a soft 8px - 12px radius to distinguish functional areas from layout containers.

## Components

### Buttons
- **Primary:** Gradient background (#D946EF to #8B5CF6), white text, pill-shaped.
- **Secondary:** Transparent background, 1px border (#A78BFA), Accent Purple text.
- **Ghost:** No background or border, Muted Text color, turns White on hover.

### Cards
- **Style:** Background #11091E, 1px border #2A1A4A, 20px corner radius.
- **Interactive:** Slight scale-up (1.02x) and border color shift to Accent Purple on hover.

### Inputs
- **Field:** Dark background (#05050A), 1px border (#2A1A4A), 12px radius. 
- **Focus State:** Border shifts to Primary Purple with a 4px soft glow.

### Navigation
- **Bottom Bar:** A frosted or solid #11091E bar. 
- **Active State:** Icons or labels use the Primary Gradient or a small gradient indicator dot beneath the icon.
- **Home Indicator:** A #2D1F4E pill-shaped element at the bottom center.

### AI Indicators
- **Glow Pulse:** Elements representing active AI "thinking" should use a breathing animation with the Primary Gradient and a 15px outer blur.