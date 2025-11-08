extends Node2D
class_name FloatableComponent

@export var float_strength: float = 0.2
#@export var smooth: bool = false

const TILESIZE : float = 16.0

var target_y: float
var parent_body: Node2D

func _ready() -> void:
	parent_body = get_parent()
	Events.connect("confirmed_new_water_level_direction", _adjust_height)
	#target_y = parent_body.global_position.y

func _process(_delta: float) -> void:
	parent_body.global_position.y = target_y
	#if abs(parent_body.global_position.y - target_y) > 0.1:
		#if smooth:
			#parent_body.global_position.y = lerp(parent_body.global_position.y, target_y, float_strength * delta)
		#else:
			#parent_body.global_position.y = target_y

func _adjust_height(water_go_up: bool) -> void:
	if water_go_up:
		target_y -= TILESIZE
	else:
		target_y += TILESIZE
	
