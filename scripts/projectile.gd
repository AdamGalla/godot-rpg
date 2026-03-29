# Projectile.gd
extends Area3D

var speed: float = 20.0
var direction: Vector3 = Vector3.ZERO
var damage: int = 20
var max_range: float = 15.0
var _traveled: float = 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	var step := direction * speed * delta
	global_position += step
	_traveled += step.length()
	if _traveled >= max_range:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		return
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()
