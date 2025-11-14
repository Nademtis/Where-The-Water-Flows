extends Area2D
#FixedCam

@onready var phantom_camera_2d: PhantomCamera2D = $".."


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		phantom_camera_2d.priority = 1


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		phantom_camera_2d.priority = 0
