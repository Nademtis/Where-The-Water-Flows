extends Node
class_name FloatableComponent

@export var tile_size: float = 16.0

var target_y: float
var parent_body: Node2D
var float_speed: float
var start_water_level: int
var current_level : float = 1

signal component_changed_level(new_level : float)

func _ready() -> void:
	parent_body = get_parent()

	float_speed = parent_body.get("float_speed")
	start_water_level = parent_body.get("start_water_level")

	target_y = parent_body.global_position.y

	if start_water_level and start_water_level != 1:
		parent_body.global_position.y += tile_size * (start_water_level - 1)
		target_y = parent_body.global_position.y

	Events.connect("confirmed_new_water_level_direction", _adjust_height)

func _process(delta: float) -> void:
	var diff_y := target_y - parent_body.global_position.y

	if abs(diff_y) < 0.1:
		parent_body.global_position.y = target_y
	else:
		var move_amount := diff_y * float_speed * delta
		parent_body.global_position.y += move_amount

func _adjust_height(water_go_up: bool) -> void:
	if water_go_up:
		current_level +=1
		print("platform height: ", current_level)
		target_y += -tile_size
	else:
		current_level -=1
		target_y += tile_size
	
	emit_signal("component_changed_level", current_level)
	
