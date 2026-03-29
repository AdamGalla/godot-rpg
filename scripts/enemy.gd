extends CharacterBody3D
## Basic enemy placeholder that idles and can be targeted.
## Extend this for patrol, chase, and attack behaviors.

@export var max_health: int = 50
@export var detection_range: float = 8.0
@export var move_speed: float = 3.0
@export var attack_range: float = 2.0
@export var attack_damage: int = 5
@export var attack_cooldown: float = 1.5

enum State { IDLE, CHASE, ATTACK, DEAD }

var current_health: int
var state: State = State.IDLE
var _target: CharacterBody3D = null
var _attack_timer: float = 0.0

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var _hbar_fill: MeshInstance3D = $HealthBar3D/Fill

signal died

func _ready() -> void:
	current_health = max_health
	add_to_group("enemies")
	_update_health_bar()

func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		return

	_attack_timer = max(_attack_timer - delta, 0.0)

	match state:
		State.IDLE:
			_check_for_player()
		State.CHASE:
			_chase_player(delta)
		State.ATTACK:
			_try_attack()

func _check_for_player() -> void:
	var players := get_tree().get_nodes_in_group("player")
	for p in players:
		if global_position.distance_to(p.global_position) <= detection_range:
			_target = p
			state = State.CHASE
			return

func _chase_player(delta: float) -> void:
	if not is_instance_valid(_target):
		state = State.IDLE
		return

	var dist := global_position.distance_to(_target.global_position)

	if dist <= attack_range:
		state = State.ATTACK
		return

	if dist > detection_range * 1.5:
		_target = null
		state = State.IDLE
		return

	nav_agent.target_position = _target.global_position
	if not nav_agent.is_navigation_finished():
		var next_pos := nav_agent.get_next_path_position()
		var dir := (next_pos - global_position).normalized()
		dir.y = 0.0
		velocity = dir * move_speed
		var target_angle := atan2(dir.x, dir.z)
		rotation.y = lerp_angle(rotation.y, target_angle, 8.0 * delta)
	move_and_slide()

func _try_attack() -> void:
	if not is_instance_valid(_target):
		state = State.IDLE
		return

	var dist := global_position.distance_to(_target.global_position)
	if dist > attack_range * 1.3:
		state = State.CHASE
		return

	if _attack_timer <= 0.0:
		if _target.has_method("take_damage"):
			_target.take_damage(attack_damage)
		_attack_timer = attack_cooldown

func take_damage(amount: int) -> void:
	current_health -= amount
	_update_health_bar()
	if current_health <= 0:
		_die()

func _update_health_bar() -> void:
	var ratio := clampf(float(current_health) / float(max_health), 0.0, 1.0)
	_hbar_fill.scale = Vector3(ratio, 1.0, 1.0)
	_hbar_fill.position = Vector3((ratio - 1.0) * 0.35, 0.0, 0.001)

func _die() -> void:
	state = State.DEAD
	died.emit()
	# Simple death: shrink and remove
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector3(0.01, 0.01, 0.01), 0.5)
	tween.tween_callback(queue_free)
