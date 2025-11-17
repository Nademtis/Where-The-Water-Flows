class_name Obelisk extends BaseInteractable

@onready var obelisk: Node2D = $mask/obelisk
@onready var active_sprite: Sprite2D = $mask/obelisk/activeSprite

@export var switch_to_activate : BaseSwitch

var player_in_range := false

var retracted_pos : Vector2 = Vector2(0, 28)
var active_pos : Vector2 = Vector2(0, 0)

const MOVE_TIME := 0.5


func _ready() -> void:
	super._ready()
	Events.connect("player_use", _on_player_use)
	
	#set correct pos
	obelisk.position = active_pos if active else retracted_pos
	
	if required_switches.is_empty():
		print("this obelisk has no switches, so is shown")
	
	if switch_to_activate:
		update_active_logic(switch_to_activate.active)
	

func _apply_state() -> void:
	var target:Vector2
	if active:
		target = active_pos
	else:
		target = retracted_pos
		update_active_logic(false)
		
	_move_to(target)



func _move_to(target: Vector2) -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(obelisk, "position", target, MOVE_TIME)

func update_active_logic(state : bool) -> void:
	if state:
		switch_to_activate.set_active(true)
		active_sprite.visible = true
		
	else:
		switch_to_activate.set_active(false)
		active_sprite.visible = false

func _on_player_use() -> void:
	if not player_in_range:
		return
	if active and switch_to_activate:
		update_active_logic(!switch_to_activate.active) # to flip the on and off
		print("Player used")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		print("player is in range")
	

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		print("player is NOT range")
		
