class_name Elevator extends BaseInteractable

@onready var frame_turned_on: Sprite2D = $wholemask/DoorContainer/FrameTurnedOn
@onready var moveable_door: Sprite2D = $wholemask/DoorContainer/moveableDoor

var door_closed_pos := Vector2 (0,0)
var door_open_pos := Vector2 (0,50)

const MOVE_TIME : float = 0.5

func _ready() -> void:
	super._ready()
	_apply_state()
	#update door frame to match amount of required switches
	

func _apply_state() -> void:
	if active:
		print("elevator active")
		frame_turned_on.visible = true
		_manage_door(true)

	else:
		print("elevator not active")
		frame_turned_on.visible = false
		_manage_door(false)
		#TODO close door / fully go down in ground?

func _manage_door(is_active : bool) -> void:
	if is_active:
		_move_to(door_open_pos)
		
	else:
		_move_to(door_closed_pos)
		
func _move_to(target: Vector2) -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(moveable_door, "position", target, MOVE_TIME)
