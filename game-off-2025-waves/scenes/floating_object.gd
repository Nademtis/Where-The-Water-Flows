extends CharacterBody2D

@export var placed_at_water_level : int = 1
@onready var floatable_component: FloatableComponent = $FloatableComponent

const TILESIZE : float = 16

func _ready() -> void:
	if placed_at_water_level:
		global_position.y += TILESIZE * placed_at_water_level
		floatable_component.target_y = global_position.y
