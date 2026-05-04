#!/usr/bin/env pwsh
# Optimize SVGs using SVGO if available

if (Get-Command svgo -ErrorAction SilentlyContinue) {
    Write-Host "Optimizing SVGs in assets/images..."
    svgo -f assets/images/
} else {
    Write-Warning "SVGO not found. Skipping optimization. Install with 'npm install -g svgo'"
}

