extends Node3D
## Spawns procedural trees and rocks on the ground plane so the world
## has visual content out of the box.  Replace with real assets later.

@export var tree_count: int = 40
@export var rock_count: int = 25
@export var spawn_radius: float = 45.0
@export var safe_zone_radius: float = 4.0  ## Keep area around origin clear

func _ready() -> void:
	_spawn_trees()
	_spawn_rocks()

func _spawn_trees() -> void:
	for i in tree_count:
		var pos := _random_position()
		var tree := _make_tree()
		add_child(tree)
		tree.global_position = pos

func _spawn_rocks() -> void:
	for i in rock_count:
		var pos := _random_position()
		var rock := _make_rock()
		add_child(rock)
		rock.global_position = pos

func _random_position() -> Vector3:
	var pos := Vector3.ZERO
	for _attempt in 10:
		pos = Vector3(
			randf_range(-spawn_radius, spawn_radius),
			0.0,
			randf_range(-spawn_radius, spawn_radius)
		)
		if pos.length() > safe_zone_radius:
			break
	return pos

func _make_tree() -> Node3D:
	var root := Node3D.new()
	var trunk_height: float = randf_range(1.5, 3.0)
	var crown_radius: float = randf_range(0.8, 1.6)
	var scale_factor: float = randf_range(0.7, 1.3)

	# Trunk
	var trunk_mesh := CylinderMesh.new()
	trunk_mesh.top_radius = 0.12 * scale_factor
	trunk_mesh.bottom_radius = 0.2 * scale_factor
	trunk_mesh.height = trunk_height
	var trunk_mat := StandardMaterial3D.new()
	trunk_mat.albedo_color = Color(0.4, 0.28, 0.15)
	var trunk_inst := MeshInstance3D.new()
	trunk_inst.mesh = trunk_mesh
	trunk_inst.position.y = trunk_height * 0.5
	trunk_inst.set_surface_override_material(0, trunk_mat)
	root.add_child(trunk_inst)

	# Crown
	var crown_mesh := SphereMesh.new()
	crown_mesh.radius = crown_radius
	crown_mesh.height = crown_radius * 1.8
	var crown_mat := StandardMaterial3D.new()
	var green_var := randf_range(-0.06, 0.06)
	crown_mat.albedo_color = Color(0.18 + green_var, 0.42 + green_var, 0.12 + green_var)
	var crown_inst := MeshInstance3D.new()
	crown_inst.mesh = crown_mesh
	crown_inst.position.y = trunk_height + crown_radius * 0.6
	crown_inst.set_surface_override_material(0, crown_mat)
	root.add_child(crown_inst)

	root.rotation.y = randf() * TAU
	return root

func _make_rock() -> MeshInstance3D:
	var mesh := BoxMesh.new()
	var s := randf_range(0.2, 0.7)
	mesh.size = Vector3(s * randf_range(0.8, 1.4), s * randf_range(0.5, 1.0), s * randf_range(0.8, 1.4))
	var mat := StandardMaterial3D.new()
	var grey := randf_range(0.35, 0.55)
	mat.albedo_color = Color(grey, grey, grey * 0.95)
	mat.roughness = 0.9
	var inst := MeshInstance3D.new()
	inst.mesh = mesh
	inst.position.y = mesh.size.y * 0.5
	inst.rotation.y = randf() * TAU
	inst.set_surface_override_material(0, mat)
	return inst
