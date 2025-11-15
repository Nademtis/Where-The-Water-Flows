class_name Elevator extends BaseInteractable
	
func _apply_state() -> void:
	if active:
		print("elevator active")
		#TODO open door
	else:
		print("elevator not active")
		#TODO close door / fully go down in ground?
