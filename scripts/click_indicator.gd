extends Node3D
## Animated ring that appears where the player right-clicks.
## Fades out and shrinks, then self-destructs.

@export var lifetime: float = 0.6
@export var start_scale: float = 1.2
@export var end_scale: float = 0.3

var _elapsed: float = 0.0

@onready var _mesh: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	scale = Vector3.ONE * start_scale

func _process(delta: float) -> void:
	_elapsed += delta
	var t: float = _elapsed / lifetime

	if t >= 1.0:
		queue_free()
		return

	# Shrink and fade
	var s: float = lerpf(start_scale, end_scale, t)
	scale = Vector3.ONE * s

	if _mesh and _mesh.get_surface_override_material(0):
		var mat: StandardMaterial3D = _mesh.get_surface_override_material(0) as StandardMaterial3D
		if mat:
			mat.albedo_color.a = 1.0 - t
