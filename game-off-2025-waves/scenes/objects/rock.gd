extends Node2D
class_name Item

@onready var hit_box: Area2D = $hit_box
@onready var static_body_coll: CollisionShape2D = $StaticBody2D/staticBodyColl

var player_in_range := false



func _ready() -> void:
	pass
	#Events.connect("player_use", _on_player_use)
	
	
func pick_up(new_pos : Vector2) -> void:
	global_position = new_pos
	static_body_coll.set_deferred("disabled", true)
	#static_body_coll.disabled = true
	
func drop(new_pos : Vector2) -> void:
	global_position = new_pos
	static_body_coll.set_deferred("disabled", false)
	
	
