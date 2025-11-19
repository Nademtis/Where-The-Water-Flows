class_name Bridge extends BaseInteractable

@onready var bridge_sprite: Sprite2D = $mask/bridgeSprite

@export var placed_at_water_level : int


var retract_post : Vector2 = Vector2(-26.0, -13.0)
var active_pos : Vector2 = Vector2(0,0)

const MOVE_TIME := 0.5

func _ready() -> void:
	super._ready()
	bridge_sprite.position = active_pos if active else retract_post

	if !placed_at_water_level:
		push_error("water level not defined")
	Events.connect("water_level_changed", anim_water)

func _apply_state() -> void:
	var target := active_pos if active else retract_post
	_move_to(target)


func _move_to(target: Vector2) -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(bridge_sprite, "position", target, MOVE_TIME)

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
