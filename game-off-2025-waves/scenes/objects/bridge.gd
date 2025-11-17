class_name Bridge extends BaseInteractable

@onready var bridge_sprite: Sprite2D = $mask/bridgeSprite

#x -26.0, y -13.0
var retract_post : Vector2 = Vector2(-26.0, -13.0)
var active_pos : Vector2 = Vector2(0,0)

const MOVE_TIME := 0.5

func _ready() -> void:
	super._ready()
	bridge_sprite.position = active_pos if active else retract_post


func _apply_state() -> void:
	var target := active_pos if active else retract_post
	_move_to(target)


func _move_to(target: Vector2) -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(bridge_sprite, "position", target, MOVE_TIME)
