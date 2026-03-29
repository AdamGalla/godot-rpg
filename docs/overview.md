# Project Overview

**Metin Godot Template** is a click-to-move 3D action RPG template built with Godot 4.6, inspired by Metin2 and League of Legends. It serves as a playable foundation for building an action RPG — the core gameplay loop is implemented and ready to be extended.

## Tech Stack

| Tool | Version | Purpose |
|------|---------|---------|
| Godot Engine | 4.6 | Game engine |
| GDScript | Built-in | Game logic scripting |
| Forward Plus | renderer | Rendering pipeline (supports SSAO, glow, fog) |
| NavigationMesh | Built-in | Pathfinding / click-to-move |

## What's Working

- **Click-to-move navigation** — right-click anywhere on the ground to move there
- **Orbiting camera** — middle-click drag to rotate, scroll wheel to zoom
- **Enemy AI** — enemies detect, chase, and attack the player with a state machine
- **Health system** — player and enemies have health; player health shown on HUD
- **HUD** — health bar, level label, skill slot placeholders (Q/W/E/R)
- **Procedural environment** — trees and rocks spawned at runtime (no assets required)
- **Click indicator** — glowing torus appears at the move target

## Controls

| Input | Action |
|-------|--------|
| Right-click | Move to location |
| Middle-click + drag | Rotate camera |
| Scroll wheel | Zoom in/out |

## Getting Started

1. Open the project in Godot 4.6+
2. Run `scenes/main.tscn` (set as main scene in project settings)
3. Right-click to move around the map

## Entry Point

`res://scenes/main.tscn` is the root scene. Everything — player, enemies, camera, HUD, environment — is either instanced or spawned from there.

## What's Not Done Yet

- Left-click targeting of enemies (stub in `player.gd`)
- Actual skill logic (slots exist in HUD, no behaviour)
- Day/night cycle (stub in `world_environment.gd`)
- Real 3D assets (all visuals are Godot primitives)
- Death screen / respawn (`player.gd` has a TODO)
