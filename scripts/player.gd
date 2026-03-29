extends CharacterBody3D
## Player character with click-to-move navigation (Metin2 / LoL style).
##
## Right-click on the ground to set a movement target.
## The player smoothly rotates and walks toward the destination.
## A click indicator ring is spawned at the target location.

# ── Movement tuning ──────────────────────────────────────────────
@export var move_speed: float = 8.0          ## Units per second
@export var rotation_speed: float = 10.0     ## Radians per second (lerp weight)
@export var arrival_threshold: float = 0.3   ## Stop within this distance of target
@export var gravity: float = 20.0            ## Downward acceleration

# ── Node references ──────────────────────────────────────────────
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var model: Node3D = $Model
@onready var animation_player: AnimationPlayer = $Model/AnimationPlayer
@onready var click_indicator_scene: PackedScene = preload("res://scenes/click_indicator.tscn")
@onready var muzzle: Marker3D = $Muzzle

const Projectile = preload("res://scenes/projectile.tscn")

# ── State ─────────────────────────────────────────────────────────
var _is_moving: bool = false
var _current_indicator: Node3D = null

# ── Signals ───────────────────────────────────────────────────────
signal started_moving
signal stopped_moving
signal health_changed(new_hp: int, max_hp: int)
signal skill_cast(skill_index: int, cooldown: float)

# ── Stats ─────────────────────────────────────────────────────────
@export var max_health: int = 100
@export var skill_q_cooldown: float = 3.0
var _skill_q_remaining: float = 0.0
var current_health: int:
	set(value):
		current_health = clampi(value, 0, max_health)
		health_changed.emit(current_health, max_health)

func _ready() -> void:
	current_health = max_health
	navigation_agent.path_desired_distance = arrival_threshold
	navigation_agent.target_desired_distance = arrival_threshold
	navigation_agent.velocity_computed.connect(_on_velocity_computed)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		print("[Player] Mouse button pressed: ", event.button_index)
		if event.button_index == MOUSE_BUTTON_LEFT:
			_handle_click(event.position)

func _process(delta: float) -> void:
	if _skill_q_remaining > 0.0:
		_skill_q_remaining = maxf(_skill_q_remaining - delta, 0.0)
	if Input.is_action_just_pressed("ui_skill_q"):
		shoot()

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	if _is_moving:
		if navigation_agent.is_navigation_finished():
			_stop_moving()
		else:
			var next_pos: Vector3 = navigation_agent.get_next_path_position()
			var direction: Vector3 = (next_pos - global_position)
			direction.y = 0.0
			direction = direction.normalized()

			if direction.length() > 0.01:
				var target_angle: float = atan2(direction.x, direction.z)
				rotation.y = lerp_angle(rotation.y, target_angle, rotation_speed * delta)

			velocity.x = direction.x * move_speed
			velocity.z = direction.z * move_speed
			navigation_agent.velocity = velocity
	else:
		velocity.x = move_toward(velocity.x, 0.0, move_speed)
		velocity.z = move_toward(velocity.z, 0.0, move_speed)

	move_and_slide()

func _on_velocity_computed(safe_velocity: Vector3) -> void:
	velocity.x = safe_velocity.x
	velocity.z = safe_velocity.z

# ── Click handling ────────────────────────────────────────────────

func _handle_click(screen_pos: Vector2) -> void:
	var camera := get_viewport().get_camera_3d()
	if not camera:
		print("[Player] ERROR: No active camera found!")
		return

	var ray_origin := camera.project_ray_origin(screen_pos)
	var ray_end := ray_origin + camera.project_ray_normal(screen_pos) * 1000.0
	var space_state := get_world_3d().direct_space_state

	var query := PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	query.collision_mask = 0b1110
	query.exclude = [self]
	var result := space_state.intersect_ray(query)

	if not result.is_empty():
		print("[Player] Clicked on: ", result.collider.name)
		return

	query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	query.collision_mask = 1
	query.exclude = [self]
	result = space_state.intersect_ray(query)

	if result.is_empty():
		print("[Player] Raycast missed ground (layer 1). Check ground collision_layer.")
		return

	print("[Player] Moving to: ", result.position)
	_move_to(result.position)

func _move_to(target: Vector3) -> void:
	navigation_agent.target_position = target
	_is_moving = true
	_play_animation("walk")
	_spawn_click_indicator(target)
	started_moving.emit()

func _stop_moving() -> void:
	_is_moving = false
	velocity = Vector3.ZERO
	_play_animation("idle")
	_remove_click_indicator()
	stopped_moving.emit()

# ── Shooting ──────────────────────────────────────────────────────

func shoot() -> void:
	if _skill_q_remaining > 0.0:
		return
	_skill_q_remaining = skill_q_cooldown
	skill_cast.emit(0, skill_q_cooldown)

	var camera := get_viewport().get_camera_3d()
	if not camera:
		return

	var mouse_pos := get_viewport().get_mouse_position()
	var ray_origin := camera.project_ray_origin(mouse_pos)
	var ray_end := ray_origin + camera.project_ray_normal(mouse_pos) * 1000.0

	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	query.exclude = [self]
	var result := space_state.intersect_ray(query)

	var target_pos: Vector3
	if result.is_empty():
		target_pos = ray_end
	else:
		target_pos = result.position

	var proj = Projectile.instantiate()
	get_tree().current_scene.add_child(proj)
	proj.global_position = muzzle.global_position
	proj.direction = (target_pos - muzzle.global_position).normalized()

# ── Visual feedback ───────────────────────────────────────────────

func _spawn_click_indicator(pos: Vector3) -> void:
	_remove_click_indicator()
	_current_indicator = click_indicator_scene.instantiate()
	get_tree().current_scene.add_child(_current_indicator)
	_current_indicator.global_position = pos + Vector3(0, 0.05, 0)

func _remove_click_indicator() -> void:
	if is_instance_valid(_current_indicator):
		_current_indicator.queue_free()
		_current_indicator = null

# ── Animation helpers ─────────────────────────────────────────────

func _play_animation(anim_name: String) -> void:
	if animation_player and animation_player.has_animation(anim_name):
		if animation_player.current_animation != anim_name:
			animation_player.play(anim_name)

# ── Public API ────────────────────────────────────────────────────

func take_damage(amount: int) -> void:
	current_health -= amount
	if current_health <= 0:
		_on_death()

func heal(amount: int) -> void:
	current_health += amount

func _on_death() -> void:
	_stop_moving()
	_play_animation("death")
	set_physics_process(false)
