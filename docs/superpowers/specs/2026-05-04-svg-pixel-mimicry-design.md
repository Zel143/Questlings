# Questlings Asset Strategy: SVG Pixel-Mimicry

## Objective

Replace heavy, static PNG sprite sheets with lightweight, dynamic, and scalable vector assets that mimic a retro/pixel-art aesthetic.

## Architecture

### 1. Vector Pipeline (SVG)

* **Format:** Standard `.svg` format for all icons and base Questling shapes.
* **Technique:** Base shapes drawn clean/smooth.
* **The "Pixel" Filter:** Apply SVG filters (`feColorMatrix`, `feComponentTransfer`, or Flutter equivalents like `ImageFiltered` or custom shaders) to downsample colors and create hard, jagged edges.
* **Benefit:** Allows infinite scaling without blur, and dynamic color swapping via code (e.g., tinting a Water Questling darker for a specific mission).

### 2. Animation (Lottie/Rive)

* **Tool:** Use Rive or Lottie for complex character animations (Idle, Cheer, Sad).
* **Aesthetic:** Export vector animations but apply the pixel-mimic filter at runtime in Flutter.
* **Benefit:** Tiny JSON/Riv files replace massive GIF/Sprite sequences. Smooth tweening under the hood, but rendered chunky.

### 3. Procedural Map/Grid (Canvas)

* **Tech:** Use Flutter's `CustomPainter`.
* **Usage:** Draw grids, progress bars, and the Co-op Goal map procedurally rather than using image tiles.
* **Benefit:** Zero asset weight. Perfect crispness on any device.

## Implementation Steps

1. **Proof of Concept (PoC):**
   * Create one simple vector SVG (e.g., the starter Water Egg).
   * Implement a Flutter `ShaderMask` or `ImageFiltered` to give it a 16-bit pixel look.
2. **Animation Integration:**
   * Import a simple Rive/Lottie animation and pass it through the same pixel filter.
3. **Pipeline Tooling:**
   * Define a build step or script to optimize SVGs before they enter the Flutter asset bundle.

## Trade-offs

* **Pros:** Dramatically reduced app size, dynamic theme/color support, resolution independence.
* **Cons:** Slightly higher CPU/GPU overhead at runtime due to filter processing; requires artists to work in vectors rather than raw pixels.
