extends Node2D
class_name Item

@onready var hit_box_coll: CollisionShape2D = $hit_box/hitBoxColl
@onready var static_body_coll: CollisionShape2D = $StaticBody2D/staticBodyColl
var original_parent : Node
var item_is_moving : bool = false

func _ready() -> void:
	original_parent = get_parent()
	print(original_parent)

func pick_up(local_target: Vector2) -> void:
	_begin_move()
	static_body_coll.set_deferred("disabled", true)
	hit_box_coll.set_deferred("disabled", true)

	var tween := get_tree().create_tween()
	tween.tween_property(self, "position", local_target, 0.25)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
	tween.finished.connect(_end_move)
	
func drop(new_pos: Vector2) -> void:
	_begin_move()
	var tween := get_tree().create_tween()
	tween.tween_property(self, "global_position", new_pos, 0.3)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
	tween.tween_callback(_disable_collisions.bind(false))
	tween.finished.connect(_end_move)
	

func _disable_collisions(is_disabled: bool) -> void:
	static_body_coll.set_deferred("disabled", is_disabled)
	hit_box_coll.set_deferred("disabled", is_disabled)
	
func _begin_move() -> void:
	item_is_moving = true

func _end_move() -> void:
	item_is_moving = false
