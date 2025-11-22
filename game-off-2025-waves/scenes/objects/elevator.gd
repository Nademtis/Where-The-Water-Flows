class_name Elevator extends BaseInteractable

@onready var frame_turned_on: Sprite2D = $wholemask/DoorContainer/FrameTurnedOn
@onready var moveable_door: Sprite2D = $wholemask/DoorContainer/moveableDoor
@onready var door_frame: Sprite2D = $wholemask/DoorContainer/DoorFrame
@onready var inner_bg: Sprite2D = $wholemask/DoorContainer/innerBG

var door_closed_pos := Vector2 (0, -10)
var door_open_pos := Vector2 (0, 40)

@onready var door_container: Node2D = $wholemask/DoorContainer
var elevator_hidden_pos := Vector2(0 , 70)
var elevator_active_pos := Vector2(0 , 0)

@onready var level_swapper_collision_shape_2d: CollisionShape2D = $elevatorCollLogic/levelSwapperArea/LevelSwapperCollisionShape2D
@onready var door_collision_shape_2d: CollisionShape2D = $elevatorCollLogic/DoorStaticBody2D/DoorCollisionShape2D
@export var next_level_path: String

#sfx
@onready var door_sliding_sfx: AudioStreamPlayer2D = $doorSlidingSFX
@onready var door_enabled_sfx: AudioStreamPlayer2D = $DoorEnabledSFX

const DOOR_MOVE_SLOW : float = 2.5
const DOOR_MOVE_FAST : float = 1


func _ready() -> void:
	super._ready()
	_apply_state() # correct colors and state
	level_swapper_collision_shape_2d.disabled = true

func _apply_state() -> void:
	if active:
		frame_turned_on.visible = true
		_manage_door(true)

	else:
		frame_turned_on.visible = false
		_manage_door(false)
		#TODO close door / fully go down in ground?

func _manage_door(is_active : bool) -> void:
	if is_active:
		_move_to(door_open_pos, DOOR_MOVE_SLOW)
		level_swapper_collision_shape_2d.disabled = false
		door_collision_shape_2d.disabled = true
		
	else:
		_move_to(door_closed_pos, DOOR_MOVE_SLOW)
		level_swapper_collision_shape_2d.disabled = true
		door_collision_shape_2d.disabled = false
	
	door_sliding_sfx.play(2.7)
	door_enabled_sfx.play()
		
func _move_to(target: Vector2, move_time : float) -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(moveable_door, "position", target, move_time)
	#tween.tween_callback(door_sliding_sfx.stop)


func _on_level_swapper_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_close_door_and_swap_level(body)
		

func _close_door_and_swap_level(body: Node2D) -> void:
	_move_to(door_closed_pos, DOOR_MOVE_FAST)
	body.set_cannot_move()
	await get_tree().create_timer(DOOR_MOVE_FAST).timeout
	animate_whole_elevator(elevator_hidden_pos, 1)
	await get_tree().create_timer(DOOR_MOVE_FAST).timeout
	print("swap levels")
	

func animate_whole_elevator(target: Vector2, move_time : float) -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(door_container, "position", target, move_time)
