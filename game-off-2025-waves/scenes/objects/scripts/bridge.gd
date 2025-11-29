class_name Bridge extends BaseInteractable

@onready var bridge_sprite: Sprite2D = $mask/bridgeSprite

@export var placed_at_water_level : int

@onready var mask: Sprite2D = $mask

#SFX
@onready var extend_sfx: AudioStreamPlayer2D = $extendSFX
@onready var retract_sfx: AudioStreamPlayer2D = $retractSFX

@onready var collision_tile_map: TileMapLayer = $CollisionTileMap
@onready var static_coll_down_left: TileMapLayer = $StaticColl_Down_left
@onready var static_coll_down_right: TileMapLayer = $StaticColl_Down_Right

@export var bridge_go_down_left : bool = false

var retract_pos : Vector2 = Vector2(-26.0, -13.0)
var active_pos : Vector2 = Vector2(0,0)

const MOVE_TIME := 1.7

func _ready() -> void:
	super._ready()
	if !bridge_go_down_left:
		#swap the mask from 80, 256, 64, 34 # this is for SW
		mask.region_rect = Rect2(144,256,64,34) # this is for SE
	
	
	#set retract_pos and active_pos based on export bool
	if bridge_go_down_left:
		retract_pos = Vector2(26.0, -13.0)
		static_coll_down_right.queue_free()
	else:
		static_coll_down_left.queue_free()
		
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


func _on_player_is_on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		#print("player entered  bridge")
		body.is_on_bridge = true


func _on_player_is_on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		#print("player exit  bridge")
		body.is_on_bridge = false
		
