class_name PressurePlate extends BaseSwitch

@onready var active_sprite: Sprite2D = $ActiveSprite
@export var placed_at_water_level : int


func _ready() -> void:
	pass
	#if !placed_at_water_level:
	#	push_error("water level not defined")
	#Events.connect("water_level_changed", anim_water)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		set_active(true)
		active_sprite.visible = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		set_active(false)
		active_sprite.visible = false


		
	
