# Extending the Template

## Common Extension Points

### Adding a New Enemy Type

1. Duplicate `scenes/enemy.tscn`
2. Create a new script that `extends` the base `enemy.gd` (or write a fresh one using the same state machine pattern)
3. Override `attack_damage`, `move_speed`, `detection_range` via export variables in the editor
4. Instance the new scene into `main.tscn`

### Adding Skills

The HUD already has four skill slot panels (Q/W/E/R). To wire them up:

1. Add `skill_1()`, `skill_2()` etc. methods to `player.gd`
2. Catch `ui_skill_1` input action (add it in Project → Input Map)
3. Implement cooldown tracking with a `Timer` node or a `time_since_cast` float

### Adding Inventory / Loot

1. Create `scripts/inventory.gd` as an autoload (Project → Project Settings → Autoloads) so any node can access it
2. Emit a signal like `item_picked_up(item_data)` from an interactable scene
3. Connect to the autoload from a new `ui/inventory.tscn` panel

### Replacing Placeholder Meshes

All characters use Godot primitive meshes (CapsuleMesh, SphereMesh). To replace:

1. Import your `.glb` / `.fbx` model into `assets/models/`
2. In the scene, swap out the `MeshInstance3D` nodes for your imported scene
3. Update the `AnimationPlayer` node to reference your model's animations
4. Keep the `CollisionShape3D` and `NavigationAgent3D` nodes — they are independent of the mesh

---

## Performance for Many Players (MMORPG Scale)

### TL;DR

**GDScript is fast enough for 200 players on the client.** You do not need C++ for rendering or moving 200 entities. The real challenges at MMORPG scale are networking and server architecture, not the scripting language.

---

### Why GDScript is Fine for 200 Players

In Godot 4, GDScript compiles to bytecode and is meaningfully faster than Godot 3. For **client-side rendering** of 200 player entities:

- The GPU handles rendering, not GDScript — draw calls are the bottleneck, not script speed
- Player movement is simple lerp/velocity math — trivially fast even in GDScript
- NavigationAgent3D pathfinding is handled by Godot's C++ internals; GDScript just reads the result

In practice, Godot games have run thousands of enemies on screen with pure GDScript. 200 players with movement/animations is well within reach.

### When to Reach for C++ (GDExtension)

Use GDExtension (Godot's C++ plugin system) only if you hit a measurable bottleneck:

| Situation | Use C++? |
|-----------|----------|
| 200 players rendering and moving | No — GDScript fine |
| Complex custom pathfinding for 1000+ AI agents | Maybe |
| Custom physics simulation (projectiles, physics-heavy combat) | Maybe |
| Server-side simulation loop at high tick rate | Yes, consider a dedicated server in Go/Rust/C++ outside Godot |
| Cryptographic/compression work | Yes |

**Rule of thumb:** Profile first. GDScript is rarely the bottleneck. GPU draw calls, NavigationServer, and network I/O are more common culprits.

### Practical Tips for 200+ Players

**Use MultiMeshInstance3D for identical entities**

Instead of 200 separate `MeshInstance3D` nodes, render them as a single draw call:

```gdscript
var mm = MultiMesh.new()
mm.transform_format = MultiMesh.TRANSFORM_3D
mm.instance_count = 200
mm.mesh = preload("res://assets/models/player.glb")

# Each frame, update transforms:
for i in 200:
    mm.set_instance_transform(i, player_transforms[i])
```

This is the single biggest rendering performance win for many characters.

**Avoid expensive per-frame operations per entity**

- Don't raycast every frame per enemy — use `Area3D` with overlap detection instead
- Stagger AI updates: update 10 enemies per frame rather than all 200 at once
- Use `call_deferred` for non-urgent logic

**Navigation at scale**

- Godot's NavigationServer runs on a background thread — it scales well
- For 200 navigating agents, consider grouping pathing requests or using flow fields instead of individual agents

**Networking architecture**

For an actual MMORPG, the server should be authoritative. Options:

| Approach | Notes |
|----------|-------|
| Godot multiplayer (`ENetMultiplayerPeer`) | Good for small player counts (< 64), built-in |
| Dedicated server in Go / Rust | Better performance at scale, worth it for true MMO |
| Relay server (e.g. Nakama, Colyseus) | Fastest to prototype with |

The client never needs C++ — only the server simulation might benefit from it at very high player counts.

### Summary

| Concern | Reality |
|---------|---------|
| "Is GDScript too slow for 200 players?" | No — rendering and movement are GPU/engine-bound |
| "Do I need C++ for good performance?" | Only for very specific CPU-heavy custom systems |
| "What will actually be slow?" | Naive per-entity raycasting, too many individual draw calls, unoptimized networking |
| "Biggest win for many entities?" | `MultiMeshInstance3D` — 200 players in one draw call |
