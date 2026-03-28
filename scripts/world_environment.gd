extends WorldEnvironment
## Manages the world environment and time of day (stub for day/night cycle).

@export var enable_day_night_cycle: bool = false
@export var day_duration_seconds: float = 600.0  # 10 minutes per full cycle

var _time_of_day: float = 0.3  # 0.0 = midnight, 0.5 = noon

func _process(delta: float) -> void:
	if not enable_day_night_cycle:
		return
	_time_of_day = fmod(_time_of_day + delta / day_duration_seconds, 1.0)
	# TODO: Adjust DirectionalLight3D rotation and environment energy
	# based on _time_of_day for a proper day/night cycle.
