class_name PressurePlate extends BaseSwitch

@onready var active_sprite: Sprite2D = $ActiveSprite
@export var placed_at_water_level : int


func _ready() -> void:
	if !placed_at_water_level:
		push_error("water level not defined")
	Events.connect("water_level_changed", anim_water)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		set_active(true)
		active_sprite.visible = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		set_active(false)
		active_sprite.visible = false


func anim_water(new_height : int) -> void:
	var target_color: Color
	if new_height > placed_at_water_level:
		# underwater → fade to translucent white (ffffff14)
		target_color = Color("5e939449")
	else:
		# above water → fade to full white
		target_color = Color.WHITE
	var t := create_tween()
	t.tween_property(self, "modulate", target_color, 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
