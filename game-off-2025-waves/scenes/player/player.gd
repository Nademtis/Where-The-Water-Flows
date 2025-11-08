extends CharacterBody2D

const MOVESPEED : float = 65

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("water_up"):
		move_water(true)
	elif Input.is_action_just_pressed("water_down"):
		move_water(false)


func _physics_process(_delta: float) -> void:
	#var direction : Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction : Vector2 = Input.get_vector("left", "right", "up", "down")
	#print(direction)
	
	if direction != Vector2.ZERO:
		velocity = direction * MOVESPEED
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()

func move_water(is_up : bool) -> void:
	Events.emit_signal("requested_water_level_direction", is_up)
