extends Area2D
class_name YsortHelper

func _ready() -> void:
	connect("body_entered",_on_body_entered)
	connect("body_exited",_on_body_exited)
	

func _on_body_entered(body: Node2D) -> void:
	var player_wrapper : Node2D = body.get_parent()
	var old_player_pos : Vector2 = body.global_position
	
	player_wrapper.global_position = global_position
	body.global_position = old_player_pos


func _on_body_exited(body: Node2D) -> void:
	
	var player_wrapper : Node2D = body.get_parent()
	var old_player_pos : Vector2 = body.global_position
	
	player_wrapper.global_position = global_position + Vector2(0, 20)
	body.global_position = old_player_pos
	
