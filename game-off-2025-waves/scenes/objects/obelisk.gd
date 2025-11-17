class_name Obelisk extends BaseInteractable

@onready var obelisk: Node2D = $mask/obelisk

@onready var active_sprite: Sprite2D = $mask/obelisk/activeSprite

var retracted_pos : Vector2 = Vector2(0, 28)
var active_pos : Vector2 = Vector2(0, 0)

const MOVE_TIME := 0.5

func _ready() -> void:
	super._ready()
	
	obelisk.position = active_pos if active else retracted_pos

func _apply_state() -> void:
	var target := active_pos if active else retracted_pos
	_move_to(target)



func _move_to(target: Vector2) -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(obelisk, "position", target, MOVE_TIME)
