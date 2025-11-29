class_name Obelisk extends BaseInteractable

@onready var obelisk: Node2D = $mask/obelisk
@onready var active_sprite: Sprite2D = $mask/obelisk/activeSprite

@export var placed_at_water_level : int
@export var switch_to_activate : BaseSwitch

@onready var collision_shape_2d: CollisionShape2D = $StaticBody2D/CollisionShape2D

var player_in_range := false

var retracted_pos : Vector2 = Vector2(0, 28)
var active_pos : Vector2 = Vector2(0, 0)

const MOVE_TIME := 0.8

#SFX
@onready var active_sfx: AudioStreamPlayer2D = $activeSFX
@onready var not_active_sfx: AudioStreamPlayer2D = $notActiveSFX
@onready var rise_sfx: AudioStreamPlayer2D = $riseSFX
@onready var go_down_sfx: AudioStreamPlayer2D = $goDownSFX
@onready var interact_indicator: InteractIndicator = $interactIndicator

@onready var point_light_2d: PointLight2D = $PointLight2D

func _ready() -> void:
	super._ready()
	Events.connect("player_use", _on_player_use)
	
	point_light_2d.hide()
	
	if !placed_at_water_level:
		push_error("water level not defined")
	Events.connect("water_level_changed", anim_water)
	
	if active:
		obelisk.position = active_pos
	else:
		obelisk.position = retracted_pos
		collision_shape_2d.set_deferred("disabled", true)
	
	if switch_to_activate:
		update_active_logic(switch_to_activate.active)
	

func _apply_state() -> void:
	var target:Vector2
	if active:
		target = active_pos
		SFX.play_sfx(rise_sfx)
		collision_shape_2d.set_deferred("disabled", false)
		
	else:
		SFX.play_sfx(go_down_sfx)
		target = retracted_pos
		collision_shape_2d.set_deferred("disabled", true)
		update_active_logic(false)
	_move_to(target)

func _move_to(target: Vector2) -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(obelisk, "position", target, MOVE_TIME)

func update_active_logic(state : bool) -> void:
	if state:
		switch_to_activate.set_active(true)
		active_sprite.visible = true
		SFX.play_sfx(active_sfx)
		point_light_2d.show()
		
		
		
	else:
		if switch_to_activate and switch_to_activate.active:
			not_active_sfx.play()
		switch_to_activate.set_active(false)
		active_sprite.visible = false
		point_light_2d.hide()
		
		
		

func _on_player_use() -> void:
	if not player_in_range:
		return
	if active and switch_to_activate:
		update_active_logic(!switch_to_activate.active) # to flip the on and off

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		
		if active:
			interact_indicator.show_indicator()

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		
		if active:
			interact_indicator.hide_indicator()
		

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
