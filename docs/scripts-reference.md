# Scripts Reference

All scripts live in `scripts/`. Each is attached to a corresponding scene node.

---

## player.gd

**Attached to:** `Player` (CharacterBody3D) in `player.tscn`  
**Group:** `"player"`

Handles player input, click-to-move pathfinding, health, and animations.

### Export Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `move_speed` | `8.0` | Units per second |
| `rotation_speed` | `10.0` | Lerp weight for turning |
| `arrival_threshold` | `0.3` | Distance to consider "arrived" |
| `gravity` | `20.0` | Downward force (units/s²) |
| `max_health` | `100` | Starting / maximum HP |

### Signals

| Signal | When emitted |
|--------|-------------|
| `started_moving` | Player begins moving to a target |
| `stopped_moving` | Player arrives or target is cleared |
| `health_changed(new_hp, max_hp)` | HP changes — HUD listens to this |

### Key Methods

| Method | Description |
|--------|-------------|
| `take_damage(amount: int)` | Reduce health, die at 0 |
| `_handle_click(event)` | Raycast to ground/enemies on right-click |
| `_play_animation(name)` | Switch AnimationPlayer state |

### How Click-to-Move Works

1. Right-click fires `_unhandled_input`
2. Two raycasts: first against layers 2–4 (entities), then layer 1 (ground)
3. Hit position passed to `navigation_agent.set_target_position()`
4. Each `_physics_process` frame: read next path position, move toward it, lerp rotation

---

## enemy.gd

**Attached to:** `Enemy` (CharacterBody3D) in `enemy.tscn`  
**Group:** `"enemies"`

Simple state-machine AI that detects, chases, and attacks the player.

### Export Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `max_health` | `50` | Enemy HP |
| `detection_range` | `8.0` | Radius to start chasing |
| `move_speed` | `3.0` | Units per second |
| `attack_range` | `2.0` | Melee attack radius |
| `attack_damage` | `5` | HP dealt per hit |
| `attack_cooldown` | `1.5` | Seconds between attacks |

### States

```
IDLE  →(player enters detection_range)→  CHASE
CHASE →(player enters attack_range)→    ATTACK
CHASE →(player leaves detection_range)→  IDLE
ATTACK→(player leaves attack_range)→    CHASE
Any   →(health <= 0)→                   DEAD
```

### Key Methods

| Method | Description |
|--------|-------------|
| `take_damage(amount: int)` | Called by player's attack logic |
| `_die()` | Tween shrink to zero, then `queue_free()` |

---

## camera_rig.gd

**Attached to:** `CameraRig` (Node3D) in `main.tscn`

Orbiting camera with zoom and smooth follow.

### Export Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `follow_target` | `NodePath` | Node to follow (set to Player) |
| `follow_speed` | `8.0` | Lerp weight for position smoothing |
| `default_distance` | `14.0` | Starting SpringArm length |
| `min_distance` | `6.0` | Closest zoom |
| `max_distance` | `28.0` | Furthest zoom |
| `zoom_step` | `1.5` | Distance change per scroll tick |
| `zoom_smooth_speed` | `8.0` | Zoom lerp speed |
| `pitch_angle` | `-55.0°` | Fixed vertical angle |
| `orbit_speed` | `0.005` | Mouse sensitivity for rotation |

### How It Works

- `_process`: lerps `global_position` toward `follow_target.global_position`
- `_unhandled_input`: middle-click drag adjusts yaw; scroll adjusts `target_distance`
- Spring length lerps toward `target_distance` each frame for smooth zoom

---

## hud.gd

**Attached to:** `HUD` (CanvasLayer) in `hud.tscn`

Connects to the player's `health_changed` signal and updates the health bar.

### Key Methods

| Method | Description |
|--------|-------------|
| `set_level(level: int)` | Updates the level label |

### How It Connects

Waits one frame in `_ready()` then calls `get_tree().get_first_node_in_group("player")` and connects to `health_changed`. This avoids load-order issues.

---

## environment_spawner.gd

**Attached to:** `EnvironmentSpawner` (Node3D) in `main.tscn`

Procedurally generates trees and rocks at startup using Godot primitive meshes.

### Export Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `tree_count` | `40` | Number of trees to spawn |
| `rock_count` | `25` | Number of rocks to spawn |
| `spawn_radius` | `45.0` | Max distance from origin |
| `safe_zone_radius` | `4.0` | Min distance from origin (keeps spawn clear) |

### What It Creates

- **Trees:** Cylinder trunk + Sphere crown, random height/colour variance
- **Rocks:** BoxMesh with random non-uniform scale, grey material

All spawned objects are `StaticBody3D` on physics layer 4 (Obstacles) so raycasts and navigation treat them correctly.

---

## click_indicator.gd

**Attached to:** `ClickIndicator` (Node3D) in `click_indicator.tscn`  
**Spawned by:** `player.gd` on each right-click move

Animates a glowing torus ring at the move target, then removes itself.

### Export Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `lifetime` | `0.6` | Seconds before auto-removal |
| `start_scale` | `1.2` | Initial ring size |
| `end_scale` | `0.3` | Final ring size (shrinks inward) |

---

## world_environment.gd

**Attached to:** `WorldEnvironment` in `main.tscn`  
**Status:** Stub — day/night cycle not yet implemented

### Export Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `enable_day_night_cycle` | `false` | Toggle (no effect yet) |
| `day_duration` | `120.0` | Seconds for a full day cycle |

**TODO:** Rotate `DirectionalLight3D` and modulate ambient energy based on `_time_of_day` (0.0–1.0).
