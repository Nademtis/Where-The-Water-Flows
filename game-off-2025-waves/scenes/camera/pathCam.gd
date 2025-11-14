extends Area2D
#Pathcam

@onready var phantom_camera_2d: PhantomCamera2D = $".."


func _ready() -> void:
	pass
	#if player_position:
		#phantom_camera_2d.follow_target = player_position
	#else:
		#push_error("player_pos_node not found in tree for pathCam")
		
	#var path_to_find : Path2D = get_parent().get_parent() # since going from area to pcam to path
	#if path_to_find:
	#	phantom_camera_2d.follow_path = path_to_find

func _process(_delta: float) -> void:
	print("PathCam follow target: ", phantom_camera_2d.follow_target)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		phantom_camera_2d.priority = 1


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		phantom_camera_2d.priority = 0
