class_name PressurePlate extends BaseSwitch

@onready var active_sprite: Sprite2D = $ActiveSprite

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		set_active(true)
		active_sprite.visible = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		set_active(false)
		active_sprite.visible = false
