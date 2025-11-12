extends Node2D
class_name FloatingPlatform

@onready var floatable_component: FloatableComponent = $FloatableComponent
@export var float_speed: float = 3.5 #higher  = faster
@export var start_water_level: int = 1  #used to replace the platforms position to align with water_level

var last_y: float
var player: Player = null

func _process(_delta: float) -> void:
	var diff_y := global_position.y - last_y
	last_y = global_position.y

	if player:
		player.global_position.y += diff_y

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if abs(body.current_player_height - floatable_component.current_level) <= 0.5:
			player = body
			print("player entered")
			var parent: Node2D = get_parent()
			body.call_deferred("reparent", parent, true)
			body.z_index = 0
			body.is_on_platform = true
		else:
			print("not at same height")

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == player:
		body.z_index = 1
		body.is_on_platform = false
		player = null
		print("player left")
