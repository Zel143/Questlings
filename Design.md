---
name: Pocket Monster Cave
colors:
  surface: '#fafaf2'
  surface-dim: '#dadad3'
  surface-bright: '#fafaf2'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f4f4ec'
  surface-container: '#eeeee6'
  surface-container-high: '#e8e9e1'
  surface-container-highest: '#e3e3db'
  on-surface: '#1a1c18'
  on-surface-variant: '#41493e'
  inverse-surface: '#2f312c'
  inverse-on-surface: '#f1f1e9'
  outline: '#717a6d'
  outline-variant: '#c1c9bb'
  surface-tint: '#2f6b2d'
  primary: '#2f6b2d'
  on-primary: '#ffffff'
  primary-container: '#98d98e'
  on-primary-container: '#246024'
  inverse-primary: '#96d68c'
  secondary: '#13648f'
  on-secondary: '#ffffff'
  secondary-container: '#8dcefe'
  on-secondary-container: '#005880'
  tertiary: '#725a39'
  on-tertiary: '#ffffff'
  tertiary-container: '#e3c49b'
  on-tertiary-container: '#675030'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#b1f3a6'
  primary-fixed-dim: '#96d68c'
  on-primary-fixed: '#002202'
  on-primary-fixed-variant: '#155217'
  secondary-fixed: '#c9e6ff'
  secondary-fixed-dim: '#8dcefe'
  on-secondary-fixed: '#001e2f'
  on-secondary-fixed-variant: '#004b6f'
  tertiary-fixed: '#feddb3'
  tertiary-fixed-dim: '#e1c299'
  on-tertiary-fixed: '#281801'
  on-tertiary-fixed-variant: '#584324'
  background: '#fafaf2'
  on-background: '#1a1c18'
  surface-variant: '#e3e3db'
typography:
  headline-lg:
    fontFamily: Spline Sans
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Spline Sans
    fontSize: 20px
    fontWeight: '700'
    lineHeight: 28px
  body-lg:
    fontFamily: Lexend
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Lexend
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-bold:
    fontFamily: Lexend
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
  pixel-display:
    fontFamily: Lexend
    fontSize: 18px
    fontWeight: '700'
    lineHeight: 24px
    letterSpacing: 0.1em
spacing:
  tile-unit: 8px
  gutter: 16px
  margin-edge: 24px
  panel-padding: 12px
---

## Brand & Style
This design system captures the cozy, low-resolution charm of early 2000s handheld gaming. It leverages a **Retro-Tactile** style, combining the pixel-perfect precision of the GBA era with the organized clarity of DS-style dual-screen interfaces.

The aesthetic is built on nostalgia and comfort, evoking the feeling of an adventurous journey through a digital wilderness. It utilizes high-contrast outlines and rigid, tile-based layouts to create a sense of mechanical reliability. The interface does not attempt to hide its digital nature; instead, it celebrates the "chunkiness" of pixelated elements, making every interaction feel deliberate and physical.

## Colors
The palette is divided into functional environmental tones and high-visibility status indicators. 

The primary "Paper" color is a soft cream (#F8F8F0), used for all main menu surfaces to reduce eye strain compared to pure white. Pastel Green, Light Blue, and Earthy Brown serve as categorical accents (e.g., Nature, Water, Earth types). All UI elements are contained by a rigorous Dark Gray (#282828) border, providing the necessary "inked" look common in 2D sprite-based games. Status colors for health and experience are vibrantly saturated to ensure they remain legible even at small pixel scales.

## Typography
To emulate the "DotGothic16" pixel aesthetic while maintaining modern accessibility, the design system utilizes **Lexend** for body and label text. Lexend’s hyper-legible, wide glyphs mimic the rhythmic spacing of retro monospaced fonts. **Spline Sans** is used for headlines to provide a slightly more geometric, technical feel.

Text should always be rendered with high contrast against the cream background. For a true retro effect, avoid sub-pixel anti-aliasing where possible; titles should feel "stamped" onto the page. Headlines often use uppercase styling to simulate the limited character sets of older cartridges.

## Layout & Spacing
The layout follows a **Rigid Tile Grid** philosophy. All components and spacing increments are multiples of an 8px base unit, mimicking the "tilemap" logic of 2D game engines. 

Windows and menus do not use fluid percentages but instead snap to fixed increments. Content is organized into "Panels" that stack vertically or sit side-by-side in a 12-column grid. Gutters are kept tight (16px) to maintain the sense of a compact, handheld screen. Large areas of empty space should be filled with subtle tiled patterns or "dithered" textures rather than remaining blank.

## Elevation & Depth
Elevation in this design system is achieved through **Hard Shadows and Outlines** rather than blurs or gradients.

1.  **The Base Layer:** The background is a solid color or a low-contrast tiled pattern.
2.  **The Panel Layer:** Menus use a 2px solid Dark Gray border.
3.  **The Depth Layer:** Every panel features a 2px offset "Drop Shadow" in a neutral gray or a darker shade of the border color. This shadow is not blurred; it is a hard-edged translation of the box shape, creating a "sticker" or "pop-up" effect.
4.  **Active State:** When a button or element is pressed, the 2px shadow disappears, and the element shifts 2px down and to the right to simulate physical compression.

## Shapes
The shape language is strictly **Sharp (0px)**. Rounding is avoided to maintain the pixel-grid alignment essential to the retro handheld aesthetic. 

Small decorative "notches" may be cut out of the corners of panels (a 4px or 8px inward square cut) to create a more mechanical, hardware-inspired look, but traditional CSS border-radius is never used. All progress bars, containers, and selection highlights must be perfectly rectangular.

## Components
- **Menu Boxes:** Primary containers using the Cream (#F8F8F0) background, 2px Dark Gray border, and a 2px hard shadow.
- **Action Buttons:** These use the Earthy Brown (#D2B48C) or Light Blue (#88C9F9) as fills. Text is centered. On hover, the border thickens or changes to a bright highlight color.
- **HP & Status Bars:** Horizontal containers with a 2px black border. The "fill" is a solid block of color (Green, Yellow, or Red based on percentage). There is no smoothing on the bar's progress; it moves in discrete 4px or 8px "chunks."
- **EXP Bars:** Thinner than HP bars, using Bright Cyan (#30C8D0), often placed directly beneath character labels or portraits.
- **Selection Cursor:** A small 16x16px pixel-art triangle or hand icon that floats to the left of the active list item, often pulsating horizontally.
- **List Items:** Simple text rows separated by 2px horizontal lines. Active items receive a Pastel Green (#98D98E) background fill.
- **Input Fields:** Recessed rectangles with a slightly darker cream background (#E8E8D0) to indicate they can be typed into.