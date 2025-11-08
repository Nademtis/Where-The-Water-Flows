extends Node2D
class_name FloatingPlatform

@onready var floatable_component: FloatableComponent = $FloatableComponent
@export var float_speed: float = 4.0 # higher = faster

var player: CharacterBody2D = null

func _process(delta: float) -> void:
	var target_y := floatable_component.target_y
	var diff_y := target_y - global_position.y

	if abs(diff_y) < 0.1:
		global_position.y = target_y
		diff_y = 0
	else:
		# Smoothly move a fraction of the remaining distance (ease-out)
		var move_amount := diff_y * float_speed * delta
		global_position.y += move_amount
		diff_y = move_amount

	# Move the player exactly by the same delta
	if player:
		player.global_position.y += diff_y

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
