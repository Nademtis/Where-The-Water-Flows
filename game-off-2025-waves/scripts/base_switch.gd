extends Node2D
class_name BaseSwitch

var active : bool = false
signal state_changed(active: bool)

func set_active(state: bool) -> void:
	if active == state:
		return
	active = state
	emit_signal("state_changed", active)
