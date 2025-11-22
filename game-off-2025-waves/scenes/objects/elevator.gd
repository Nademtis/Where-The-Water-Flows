class_name Elevator extends BaseInteractable

@onready var frame_turned_on: Sprite2D = $wholemask/DoorContainer/FrameTurnedOn
@onready var moveable_door: Sprite2D = $wholemask/DoorContainer/moveableDoor

var door_closed_pos := Vector2 (0,0)
var door_open_pos := Vector2 (0,50)

@onready var door_container: Node2D = $wholemask/DoorContainer
var elevator_hidden_pos := Vector2(0 , 70)
var elevator_active_pos := Vector2(0 , 0)

@onready var level_swapper_collision_shape_2d: CollisionShape2D = $levelSwapperArea/LevelSwapperCollisionShape2D
@onready var door_collision_shape_2d: CollisionShape2D = $DoorStaticBody2D/DoorCollisionShape2D
@export var next_level_path: String

const MOVE_TIME : float = 0.8

func _ready() -> void:
	super._ready()
	_apply_state() # correct colors and state
	level_swapper_collision_shape_2d.disabled = true

func _apply_state() -> void:
	if active:
		#print("elevator active")
		frame_turned_on.visible = true
		_manage_door(true)

	else:
		#print("elevator not active")
		frame_turned_on.visible = false
		_manage_door(false)
		#TODO close door / fully go down in ground?

func _manage_door(is_active : bool) -> void:
	if is_active:
		_move_to(door_open_pos)
		level_swapper_collision_shape_2d.disabled = false
		door_collision_shape_2d.disabled = true
		
	else:
		_move_to(door_closed_pos)
		level_swapper_collision_shape_2d.disabled = true
		door_collision_shape_2d.disabled = false
		
		
func _move_to(target: Vector2) -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(moveable_door, "position", target, MOVE_TIME)


func _on_level_swapper_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		#body.can_move = false
		print("swap levels")
