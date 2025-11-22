class_name PressurePlate extends BaseSwitch

@onready var active_sprite: Sprite2D = $ActiveSprite
@export var placed_at_water_level : int

var item_is_on := false

#sfx
@onready var active_sfx: AudioStreamPlayer2D = $activeSFX
@onready var not_active_sfx: AudioStreamPlayer2D = $notActiveSFX

func _ready() -> void:
	if !placed_at_water_level:
		push_error("water level not defined")
	Events.connect("water_level_changed", anim_water)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		set_active(true)
		active_sprite.visible = true

func set_active(state: bool) -> void:
	var previous_active := active
	super(state)
	if previous_active != active:
		if active:
			active_sfx.play()
		else:
			not_active_sfx.play()

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		if !item_is_on: # only set not active is item is not on
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


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("item"):
		set_active(true)
		active_sprite.visible = true
		item_is_on = true


func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("item"):
		set_active(false)
		active_sprite.visible = false
		item_is_on = false
		
