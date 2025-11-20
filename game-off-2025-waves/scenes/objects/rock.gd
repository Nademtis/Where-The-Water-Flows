extends Node2D
class_name Item

@onready var hit_box_coll: CollisionShape2D = $hit_box/hitBoxColl
@onready var static_body_coll: CollisionShape2D = $StaticBody2D/staticBodyColl




func pick_up(local_target: Vector2) -> void:
	static_body_coll.set_deferred("disabled", true)
	hit_box_coll.set_deferred("disabled", true)

	var tween := get_tree().create_tween()
	tween.tween_property(self, "position", local_target, 0.25)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

func drop(new_pos: Vector2) -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(self, "global_position", new_pos, 0.3)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
	tween.tween_callback(_enable_collisions.bind())

func _enable_collisions() -> void:
	static_body_coll.set_deferred("disabled", false)
	hit_box_coll.set_deferred("disabled", false)
