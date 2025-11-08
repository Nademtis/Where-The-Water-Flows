extends Node
class_name FloatableComponent

@export var tile_size: float = 16.0

var target_y: float
var parent_body: Node2D

func _ready() -> void:
	parent_body = get_parent()
	# Initialize target_y to current position
	target_y = parent_body.global_position.y
	
	# Connect to your global water-level event
	Events.connect("confirmed_new_water_level_direction", _adjust_height)

func _adjust_height(water_go_up: bool) -> void:
	if water_go_up:
		target_y -= tile_size
	else:
		target_y += tile_size
