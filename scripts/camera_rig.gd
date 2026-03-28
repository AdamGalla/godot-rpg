extends Node3D
## Orbiting camera rig that follows the player.
##
## Provides a Metin2 / League-style top-down angled view with:
## - Smooth follow via lerp
## - Middle-mouse orbit rotation
## - Scroll wheel zoom
## - Configurable pitch angle and distance

# ── Configuration ─────────────────────────────────────────────────
@export var follow_target: NodePath          ## Path to the player node
@export var follow_speed: float = 8.0        ## How quickly the camera catches up
@export var default_distance: float = 14.0   ## Distance from player
@export var min_distance: float = 6.0        ## Minimum zoom
@export var max_distance: float = 28.0       ## Maximum zoom
@export var zoom_step: float = 1.5           ## Distance change per scroll tick
@export var zoom_smooth_speed: float = 8.0   ## Zoom interpolation speed
@export var pitch_angle: float = -55.0       ## Camera tilt in degrees (negative = look down)
@export var orbit_speed: float = 0.005       ## Mouse sensitivity for orbiting

# ── Internal state ────────────────────────────────────────────────
var _target_node: Node3D
var _current_distance: float
var _target_distance: float
var _yaw: float = 0.0       ## Horizontal orbit angle (radians)
var _is_orbiting: bool = false

@onready var _spring_arm: SpringArm3D = $SpringArm3D
@onready var _camera: Camera3D = $SpringArm3D/Camera3D

func _ready() -> void:
	_current_distance = default_distance
	_target_distance = default_distance
	_spring_arm.spring_length = default_distance
	_spring_arm.rotation_degrees.x = pitch_angle

	if follow_target:
		_target_node = get_node(follow_target)

func _unhandled_input(event: InputEvent) -> void:
	# Middle mouse button = orbit
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			_is_orbiting = event.pressed
		# Scroll wheel zoom
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_target_distance = max(_target_distance - zoom_step, min_distance)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_target_distance = min(_target_distance + zoom_step, max_distance)

	# Mouse motion while orbiting
	if event is InputEventMouseMotion and _is_orbiting:
		_yaw -= event.relative.x * orbit_speed

func _physics_process(delta: float) -> void:
	if not _target_node:
		if follow_target:
			_target_node = get_node_or_null(follow_target)
		return

	# Smoothly follow the target position
	var target_pos: Vector3 = _target_node.global_position
	global_position = global_position.lerp(target_pos, follow_speed * delta)

	# Apply orbit rotation
	rotation.y = _yaw

	# Smooth zoom
	_current_distance = lerpf(_current_distance, _target_distance, zoom_smooth_speed * delta)
	_spring_arm.spring_length = _current_distance

func get_camera() -> Camera3D:
	return _camera
