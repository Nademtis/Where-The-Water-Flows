class_name Elevator extends BaseInteractable
@onready var frame_turned_on: Sprite2D = $wholemask/DoorContainer/FrameTurnedOn

func _apply_state() -> void:
	if active:
		print("elevator active")
		frame_turned_on.visible = true
		#TODO open door
	else:
		print("elevator not active")
		frame_turned_on.visible = false
		
		#TODO close door / fully go down in ground?
