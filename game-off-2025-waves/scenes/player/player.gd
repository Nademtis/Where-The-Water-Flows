extends CharacterBody2D

const MOVESPEED : float = 2500

func _physics_process(delta: float) -> void:
	#var direction : Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction : Vector2 = Input.get_vector("left", "right", "up", "down")
	#print(direction)
	
	if direction != Vector2.ZERO:
		velocity = direction * MOVESPEED * delta
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()
