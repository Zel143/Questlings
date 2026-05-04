#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;          // Size of the widget/canvas
uniform sampler2D uTexture;  // The image to filter
uniform vec2 uTextureSize;   // Original resolution (pixel art size)

out vec4 fragColor;

void main() {
    vec2 uv = FlutterFragCoord().xy / uSize;
    
    // Scale UV to texel space
    vec2 texelCoord = uv * uTextureSize;
    
    // Calculate the derivative to find the screen-pixel size in texel space
    vec2 duv = fwidth(texelCoord);
    
    // Sharp Bilinear formula:
    // Interpolate only within the 'duv' range at the edge of each texel
    vec2 sharpUv = floor(texelCoord) + 0.5 + 
                   clamp((fract(texelCoord) - 0.5 + duv) / duv, 0.0, 1.0);
    
    // Convert back to normalized 0.0 - 1.0 range
    vec2 finalUv = sharpUv / uTextureSize;
    
    fragColor = texture(uTexture, finalUv);
}
