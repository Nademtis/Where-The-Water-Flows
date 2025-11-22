extends Node2D
class_name BaseInteractable

var active : bool = false
@export var required_switches: Array[BaseSwitch] = []

func _ready() -> void:
	for sw in required_switches:
		sw.state_changed.connect(_on_switch_changed)
	_evaluate()
		

func _on_switch_changed(_state : bool) -> void:
	_evaluate()

func _evaluate() -> void:
	for sw in required_switches:
		if not sw.active:
			set_active(false)
			return
	set_active(true)

func set_active(state: bool) -> void:
	if active == state:
		return
	active = state
	_apply_state()

func get_active_switch_count() -> int:
	var count := 0
	for sw: BaseSwitch in required_switches:
		if sw.active:
			count += 1
	return count

# when the interactable is active this is called
func _apply_state() -> void: # use in parent scripts
	pass
