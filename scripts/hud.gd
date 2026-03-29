extends CanvasLayer
## Heads-up display with health bar, level display, and skill bar placeholders.

@onready var health_bar: ProgressBar = $MarginContainer/VBoxContainer/TopBar/HealthBar
@onready var health_label: Label = $MarginContainer/VBoxContainer/TopBar/HealthBar/HealthLabel
@onready var level_label: Label = $MarginContainer/VBoxContainer/TopBar/LevelLabel
@onready var skill_bar: HBoxContainer = $MarginContainer/VBoxContainer/BottomBar/SkillBar
@onready var _q_overlay: ColorRect = $MarginContainer/VBoxContainer/BottomBar/SkillBar/Skill1/CooldownOverlay
@onready var _q_cd_label: Label = $MarginContainer/VBoxContainer/BottomBar/SkillBar/Skill1/CooldownLabel

var _player: CharacterBody3D
var _q_remaining: float = 0.0
var _q_total: float = 1.0

func _ready() -> void:
	await get_tree().process_frame
	_player = get_tree().get_first_node_in_group("player")
	if _player:
		if _player.has_signal("health_changed"):
			_player.health_changed.connect(_on_health_changed)
			_on_health_changed(_player.current_health, _player.max_health)
		if _player.has_signal("skill_cast"):
			_player.skill_cast.connect(_on_skill_cast)

func _process(delta: float) -> void:
	if _q_remaining > 0.0:
		_q_remaining = maxf(_q_remaining - delta, 0.0)
		_q_cd_label.text = "%.1f" % _q_remaining if _q_remaining > 0.0 else ""
		var ratio := _q_remaining / _q_total
		_q_overlay.anchor_bottom = ratio
		if _q_remaining == 0.0:
			_q_overlay.visible = false
			_q_cd_label.visible = false

func _on_health_changed(current: int, maximum: int) -> void:
	if health_bar:
		health_bar.max_value = maximum
		health_bar.value = current
	if health_label:
		health_label.text = "%d / %d" % [current, maximum]

func _on_skill_cast(skill_index: int, cooldown: float) -> void:
	if skill_index == 0:
		_q_total = cooldown
		_q_remaining = cooldown
		_q_overlay.anchor_top = 0.0
		_q_overlay.anchor_bottom = 1.0
		_q_overlay.visible = true
		_q_cd_label.visible = true

func set_level(level: int) -> void:
	if level_label:
		level_label.text = "Lv. %d" % level
