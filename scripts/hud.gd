extends CanvasLayer
## Heads-up display with health bar, level display, and skill bar placeholders.

@onready var health_bar: ProgressBar = $MarginContainer/VBoxContainer/TopBar/HealthBar
@onready var health_label: Label = $MarginContainer/VBoxContainer/TopBar/HealthBar/HealthLabel
@onready var level_label: Label = $MarginContainer/VBoxContainer/TopBar/LevelLabel
@onready var skill_bar: HBoxContainer = $MarginContainer/VBoxContainer/BottomBar/SkillBar

var _player: CharacterBody3D

func _ready() -> void:
	# Find the player in the scene tree
	await get_tree().process_frame
	_player = get_tree().get_first_node_in_group("player")
	if _player and _player.has_signal("health_changed"):
		_player.health_changed.connect(_on_health_changed)
		_on_health_changed(_player.current_health, _player.max_health)

func _on_health_changed(current: int, maximum: int) -> void:
	if health_bar:
		health_bar.max_value = maximum
		health_bar.value = current
	if health_label:
		health_label.text = "%d / %d" % [current, maximum]

func set_level(level: int) -> void:
	if level_label:
		level_label.text = "Lv. %d" % level
