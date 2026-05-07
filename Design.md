# QUESTLINGS: 8-BIT DESIGN SYSTEM
## CONCEPTUALIZED BY GOOGLE STITCH

```text
  _____ _______ _____ _______ _____ _    _ 
 / ____|__   __|_   _|__   __/ ____| |  | |
| (___    | |    | |    | | | |    | |__| |
 \___ \   | |    | |    | | | |    |  __  |
 ____) |  | |   _| |_   | | | |____| |  | |
|_____/   |_|  |_____|  |_|  \_____|_|  |_|
                                           
   T H E   G O O G L E   S T I T C H   W A Y
```

---

## 1. THE VISION: "RETRO-TACTILE MODERNISM"

The **8-bit Design Idea** for Questlings is not just about nostalgia; it is about **visual clarity** and **functional weight**. By using a low-resolution aesthetic, we strip away the distractions of modern fluid UI and replace them with "chunky," deliberate interactions that make habit completion feel as significant as a physical achievement.

### Core Philosophy
*   **Stitched Precision:** Every pixel is placed with intent. We don't use "auto-layouts" that break the grid; we snap to it.
*   **Meaningful Constraints:** By limiting our palette and resolution, we force the user to focus on the core habit data.

---

## 2. SYSTEM ARCHITECTURE (THE PIXEL GRID)

Everything in Questlings is built on a **Base-8 Tile System**.

*   **The 8px Unit:** All margins, paddings, and component sizes must be multiples of 8.
*   **Resolution Simulation:** While the app runs on high-res screens, the internal coordinate system for sprites and UI elements should simulate a **160x144 viewport** (Classic Handheld resolution) or a **240x160 viewport** (Advanced Handheld).
*   **Anti-Aliasing:** Strictly forbidden. Borders must be crisp. If a line is diagonal, it must "step" in blocks.

---

## 3. COMPONENT DESIGN (8-BITIFYING THE UI)

| Modern Component | 8-Bit Transition (The Stitch Idea) |
| :--- | :--- |
| **Material Cards** | **Panel Boxes:** 2px solid black borders with a 2px hard drop-shadow (offset +2, +2). |
| **Circular Progress** | **Segmented Bars:** Progress is shown in 8x8 or 4x4 blocks. No smooth filling. |
| **Soft Buttons** | **Press-Blocks:** Buttons that shift 2px down when pressed, hiding their shadow to simulate physical depth. |
| **System Fonts** | **DotGothic16 / Lexend:** Fonts that maintain a monospaced, rhythmic spacing reminiscent of terminal outputs. |

---

## 4. DYNAMIC FEEDBACK (STITCHING ACTION TO REWARD)

The 8-bit "Idea" comes alive through movement. We use **Low-Frame-Rate Animations** (approx. 8-12 FPS) to give the app a hand-crafted feel.

1.  **The "Pop" Effect:** When a habit is completed, the Questling should not "fade in"—it should "spawn" with a 2-frame scale-up animation.
2.  **Energy Orbs:** Habit energy is represented by 4x4px flashing squares that travel in straight lines or 45-degree angles toward the total pool.
3.  **State Signaling:** 
    *   `HEALTHY`: Full-color sprite with idle bounce.
    *   `SICK`: Dithered (checkerboard pattern) or grayscale sprite.
    *   `EVOLVING`: A "flashing" effect alternating between white and the original sprite.

---

## 5. THE GOOGLE STITCH PALETTE

We use a **Limited 16-Color Palette** per screen to maintain aesthetic cohesion.

*   **Primary Background:** `#F8F8F0` (Old Paper/Parchment)
*   **Secondary Surface:** `#E8E8D0` (Recessed Areas)
*   **Action Primary:** `#2F6B2D` (Forest Green)
*   **Warning/Sick:** `#BA1A1A` (Critical Red)
*   **Shadow/Ink:** `#282828` (Dark Charcoal)

---

## 6. IMPLEMENTATION STEPS

1.  **Texture Maps:** Create a global "8-bit Atlas" for all icons and sprites.
2.  **Custom Painters:** Use Flutter `CustomPainter` to draw pixel-perfect borders that don't blur on device scaling.
3.  **Haptic Synthesis:** Match every 8-bit visual with a short, sharp vibration (haptic feedback) to reinforce the "Tactile" idea.

---

```text
  __________________________________________________________
 /                                                          \
|  STITCHED WITH CARE BY GOOGLE STITCH © 2026                |
|  "THE FUTURE OF PRODUCTIVITY IS PIXELATED."               |
 \__________________________________________________________/
```
