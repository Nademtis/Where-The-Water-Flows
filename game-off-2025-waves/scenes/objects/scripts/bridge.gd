class_name Bridge extends BaseInteractable

@onready var bridge_sprite: Sprite2D = $mask/bridgeSprite

@export var placed_at_water_level : int

#SFX
@onready var extend_sfx: AudioStreamPlayer2D = $extendSFX
@onready var retract_sfx: AudioStreamPlayer2D = $retractSFX

@onready var collision_tile_map: TileMapLayer = $CollisionTileMap
#const COLL_1_UPPER : Vector2i = Vector2i(-1, -1)
#const COLL_2_UPPER : Vector2i = Vector2i(-1, 0)
#const COLL_1_LOWER : Vector2i = Vector2i(0, 0)
#const COLL_2_LOWER : Vector2i = Vector2i(-1, 1)

var retract_pos : Vector2 = Vector2(-26.0, -13.0)
var active_pos : Vector2 = Vector2(0,0)

const MOVE_TIME := 0.5

func _ready() -> void:
	super._ready()
	bridge_sprite.position = active_pos if active else retract_pos

	if !placed_at_water_level:
		push_error("water level not defined")
	Events.connect("water_level_changed", anim_water)

func _apply_state() -> void:
	var target := retract_pos
	if active:
		target = active_pos
		extend_sfx.play()
		_move_to(target, true)
	else:
		_update_coll(false) # update coll instantly
		target = retract_pos
		retract_sfx.play()
		_move_to(target, false)


func _move_to(target: Vector2, is_extended : bool) -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(bridge_sprite, "position", target, MOVE_TIME)
	tween.tween_callback(_update_coll.bind(is_extended))
	
func _update_coll(is_extended : bool) -> void:
	collision_tile_map.set_deferred("collision_enabled", !is_extended) # when extended we do not want coll 
	#collision_tile_map.collision_enabled = !is_extended

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
