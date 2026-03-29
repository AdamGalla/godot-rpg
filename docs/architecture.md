# Architecture

## Directory Structure

```
metin-godot-template/
├── scenes/          # .tscn scene files (world, player, enemy, HUD, effects)
├── scripts/         # .gd script files (one per system)
├── assets/          # fonts/, models/, textures/ (empty — placeholder)
├── addons/          # Godot plugins (empty — none installed)
├── ui/              # Additional UI scenes (empty — HUD lives in scenes/)
├── docs/            # This documentation
├── project.godot    # Engine config, input map, physics layers
└── icon.svg         # Project icon
```

## Scene Hierarchy (main.tscn)

```
Main (Node3D)
├── WorldEnvironment          # Sky, ambient light, fog, SSAO, glow
├── DirectionalLight3D        # Main sun (warm, shadows on)
├── FillLight                 # Secondary cool fill light (no shadows)
├── NavigationRegion3D        # Baked navmesh covering the play area
│   ├── Ground (StaticBody3D) # 100×100 plane, physics layer 1
│   ├── Player                # Instance of player.tscn
│   ├── Enemy1/2/3            # Instances of enemy.tscn
├── CameraRig                 # Node3D + SpringArm3D + Camera3D
├── HUD                       # Instance of hud.tscn (CanvasLayer)
└── EnvironmentSpawner        # Spawns trees and rocks at _ready()
```

## Core Patterns

### Signals (event bus between nodes)

```gdscript
# player.gd
signal started_moving
signal stopped_moving
signal health_changed(new_hp: int, max_hp: int)  # → hud.gd listens

# enemy.gd
signal died
```

Prefer signals over direct node references to keep systems decoupled.

### Groups (global entity lookup)

```gdscript
"player"    # assigned in player.tscn; used by enemy.gd to find target
"enemies"   # assigned in enemy.gd _ready(); used by player for targeting
```

Use `get_tree().get_first_node_in_group()` or `get_nodes_in_group()` when you need to find entities without a hard reference.

### State Machine (enemy AI)

`enemy.gd` uses an `enum State { IDLE, CHASE, ATTACK, DEAD }` and a `match` block in `_physics_process` to transition between states. Each state has clear entry/exit conditions. Add new enemy behaviours by extending this pattern.

### Navigation

All movement — player and enemies — goes through `NavigationAgent3D`. Call `navigation_agent.set_target_position(pos)` and read `navigation_agent.get_next_path_position()` each physics frame. Never move CharacterBody3D directly to a target.

### Input Handling

- `_unhandled_input` — for click events (doesn't fire if UI consumes the event)
- `_physics_process` — for movement and AI (frame-rate independent via `delta`)
- `_process` — for animations and visual-only updates

## Physics Layers (3D)

| Layer | Name | Used By |
|-------|------|---------|
| 1 | Ground | StaticBody3D floor, raycasts for click-to-move |
| 2 | Player | Player CharacterBody3D |
| 3 | Enemies | Defined in project.godot (scenes use layer 4) |
| 4 | Obstacles | Enemy CharacterBody3D, procedural trees/rocks |

The click raycast in `player.gd` first checks layers 2–4 (to detect enemies/objects), then falls back to layer 1 (ground) if nothing is hit.

## Rendering Setup

| Feature | Setting |
|---------|---------|
| Renderer | Forward Plus |
| MSAA | 2× |
| SSAO | Enabled (radius 2.0, intensity 1.5) |
| Glow | Enabled |
| Fog | Enabled (density 0.002) |
| Ambient light | 0.4 energy |

## Where to Put New Things

| What | Where |
|------|-------|
| New game system (inventory, skills, loot) | `scripts/` + new scene in `scenes/` |
| New enemy type | Duplicate `enemy.tscn`, new script extending `enemy.gd` |
| UI panels | `scenes/` or `ui/` as CanvasLayer children |
| Sound / music | `assets/` — add `AudioStreamPlayer` nodes to main or player |
| 3D models | `assets/models/` — replace placeholder MeshInstance3D nodes |
| Fonts | `assets/fonts/` — assign via theme in HUD scene |
| Godot plugins | `addons/` — enable in Project → Project Settings → Plugins |
