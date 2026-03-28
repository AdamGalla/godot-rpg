# Metin / LoL Style Game Template — Godot 4.3

A click-to-move 3D game template inspired by Metin2 and League of Legends.

## Features

- **Click-to-move navigation** — Right-click on the ground to move your character via NavigationAgent3D pathfinding
- **Orbiting camera** — Top-down angled view that follows the player, with middle-mouse orbit and scroll zoom
- **Click indicator** — Glowing ring animation at the click target that shrinks and fades
- **HUD** — Health bar, level display, and 4 skill slot placeholders (Q/W/E/R)
- **Enemy AI** — Basic state machine (idle → chase → attack → dead) with navigation
- **Procedural environment** — Trees and rocks spawned at runtime so the world isn't empty
- **Day/night stub** — WorldEnvironment script ready for a day/night cycle
- **Collision layers** — Ground (1), Player (2), Enemies (3), Obstacles (4)

## Controls

| Input | Action |
|---|---|
| Right-click | Move to location |
| Left-click | Target/interact (stub) |
| Middle-mouse drag | Orbit camera |
| Scroll wheel | Zoom in/out |

## Project structure

```
scenes/
  main.tscn            — Root scene (world, lighting, nav mesh, camera, HUD)
  player.tscn          — Player character with capsule model + animations
  enemy.tscn           — Enemy with capsule model + AI state machine
  click_indicator.tscn — Animated ring at click target
  hud.tscn             — Health bar + skill bar UI

scripts/
  player.gd            — Click-to-move, health, raycasting, animation
  camera_rig.gd        — SpringArm3D orbit camera with zoom
  enemy.gd             — Idle/chase/attack/dead state machine
  click_indicator.gd   — Shrink + fade self-destruct
  hud.gd               — Binds to player health signal
  environment_spawner.gd — Procedural trees and rocks
  world_environment.gd — Day/night cycle stub
```

## Getting started

1. Open the project in Godot 4.3+
2. Hit F5 — the main scene runs automatically
3. Right-click the ground to move your character

## Extending

- **Replace placeholder meshes** — swap the capsule/sphere primitives with real character models (`.glb` / `.gltf`)
- **Add real animations** — import Mixamo or custom animations and wire them into the AnimationPlayer
- **Skills system** — the HUD skill slots are ready; connect keyboard inputs (Q/W/E/R) to skill scripts
- **Enemy variety** — duplicate `enemy.tscn`, change stats/colors, add patrol waypoints
- **Multiplayer** — the architecture separates player input from movement, making it ready for SpacetimeDB or Godot multiplayer integration
- **Inventory / loot** — add an inventory system and drop tables on enemies
