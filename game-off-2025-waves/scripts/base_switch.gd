extends Node2D
class_name BaseSwitch

#used to override a switch
@export var override_active : bool = false

var active : bool = false
signal state_changed(active: bool)

func _ready() -> void:
	if override_active:
		active = true
		emit_signal("state_changed", active)

func set_active(state: bool) -> void:
	if override_active:
		return
	
	if active == state:
		return
	active = state
	emit_signal("state_changed", active)
