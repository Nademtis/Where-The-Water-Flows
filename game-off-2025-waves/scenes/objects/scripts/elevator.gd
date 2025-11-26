class_name Elevator extends BaseInteractable

@onready var frame_turned_on: Sprite2D = $wholemask/DoorContainer/FrameTurnedOn
@onready var moveable_door: Sprite2D = $wholemask/DoorContainer/moveableDoor
@onready var door_frame: Sprite2D = $wholemask/DoorContainer/DoorFrame
@onready var inner_bg: Sprite2D = $wholemask/DoorContainer/innerBG

var door_closed_pos := Vector2 (0, -10)
var door_open_pos := Vector2 (0, 40)

@onready var lamp_container: Node2D = $wholemask/DoorContainer/LampContainer
var lamps_array: Array[ColorRect]
const LAMP_ENABLED_COLOR = Color("cd92c5")
const LAMP_DISNABLED_COLOR = Color("536873")

@onready var door_container: Node2D = $wholemask/DoorContainer
var elevator_hidden_pos := Vector2(0 , 70)
var elevator_active_pos := Vector2(0 , 0)

@onready var level_swapper_collision_shape_2d: CollisionShape2D = $elevatorCollLogic/levelSwapperArea/LevelSwapperCollisionShape2D
@onready var door_collision_shape_2d: CollisionShape2D = $elevatorCollLogic/DoorStaticBody2D/DoorCollisionShape2D
@export var next_level_path: String

#sfx
@onready var door_sliding_sfx: AudioStreamPlayer2D = $doorSfx/doorSlidingSFX
@onready var door_enabled_sfx: AudioStreamPlayer2D = $doorSfx/DoorEnabledSFX
@onready var elevator_rise_or_down: AudioStreamPlayer2D = $doorSfx/elevatorRiseOrDown

const DOOR_MOVE_SLOW : float = 2.5
const DOOR_MOVE_FAST : float = 1
var door_tween: Tween
var whole_elevator_tween : Tween

const REQUIRED_SWITCHES := {
	"Elevator-One": 1,
	"Elevator-Two": 2,
	"Elevator-Three": 3,
}

func _ready() -> void:
	_validate_switch_count()
	super._ready()
	lamps_array.append_array(lamp_container.get_children())
	_apply_state() # correct colors and state
	level_swapper_collision_shape_2d.disabled = true
	
	if required_switches.size() == 1:
		door_container.position = elevator_active_pos
	elif required_switches.size() > 0:
		door_container.position = elevator_hidden_pos

func _evaluate() -> void:
	super._evaluate()
	_update_lamp()
	
	#animate the whole elevator pos and play sound
	if door_container.position != elevator_active_pos:
		if required_switches.size() == 1: #door with 1 switch should just
			door_container.position = elevator_active_pos
		elif get_active_switch_count() > 0:
			animate_whole_elevator(elevator_active_pos, DOOR_MOVE_SLOW)
			if !elevator_rise_or_down.playing: # only play this if not allready playing
				SFX.play_sfx(elevator_rise_or_down, 0.6)
			

func _apply_state() -> void:
	if active:
		frame_turned_on.visible = true
		_manage_door(true)

	else:
		frame_turned_on.visible = false
		_manage_door(false)

func _manage_door(is_active : bool) -> void:
	if is_active:
		_move_to(door_open_pos, DOOR_MOVE_SLOW, false)
		
	else:
		_move_to(door_closed_pos, DOOR_MOVE_SLOW, true)
		#level_swapper_collision_shape_2d.disabled = true
		#door_collision_shape_2d.disabled = false
		level_swapper_collision_shape_2d.set_deferred("disabled", true)
		door_collision_shape_2d.set_deferred("disabled", false)
		
	
	
	SFX.play_sfx(door_sliding_sfx, 2.7)
	SFX.play_sfx(door_enabled_sfx)
		
func _move_to(target: Vector2, move_time : float, door_is_closed : bool) -> void:
	if door_tween and door_tween.is_running():
		door_tween.kill()

	door_tween = get_tree().create_tween()
	door_tween.tween_property(moveable_door, "position", target, move_time)
	door_tween.tween_callback(_door_collisions.bind(door_is_closed))

func _door_collisions(door_is_closed : bool) -> void:
	if door_is_closed:
		#level_swapper_collision_shape_2d.disabled = true
		level_swapper_collision_shape_2d.set_deferred("disabled", true)
		
		#door_collision_shape_2d.disabled = false
		door_collision_shape_2d.set_deferred("disabled", false)
		
	else:
		#level_swapper_collision_shape_2d.disabled = false
		level_swapper_collision_shape_2d.set_deferred("disabled", false)
		
		#door_collision_shape_2d.disabled = true
		door_collision_shape_2d.set_deferred("disabled", true)
		

func _on_level_swapper_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_close_door_and_swap_level(body)
		

func _update_lamp() -> void:
	var active_count : int = get_active_switch_count()
	var lamp_total : int = lamps_array.size()
	
	for i : int in range(lamp_total):
		var lamp := lamps_array[i]
		if i < active_count:
			lamp.color = LAMP_ENABLED_COLOR
		else:
			lamp.color = LAMP_DISNABLED_COLOR

func _close_door_and_swap_level(body: Node2D) -> void:
	_move_to(door_closed_pos, DOOR_MOVE_FAST, true)
	body.set_cannot_move()
	await get_tree().create_timer(DOOR_MOVE_FAST).timeout
	animate_whole_elevator(elevator_hidden_pos, DOOR_MOVE_FAST)
	await get_tree().create_timer(DOOR_MOVE_FAST).timeout
	print("swap levels")
	Events.emit_signal("load_new_level", next_level_path)
	

func animate_whole_elevator(target: Vector2, move_time : float) -> void:
	if whole_elevator_tween and whole_elevator_tween.is_running():
		return
		#whole_elevator_tween.kill()
	
	whole_elevator_tween = get_tree().create_tween()
	whole_elevator_tween.tween_property(door_container, "position", target, move_time)
	

func _validate_switch_count() -> void:
	var scene_name := get_name()

	for prefix : String in REQUIRED_SWITCHES.keys():
		if scene_name.begins_with(prefix):
			var required : int = REQUIRED_SWITCHES[prefix]
			if required_switches.size() != required:
				push_error(
					"%s expects %d switches, but %d were assigned." % [
						scene_name,
						required,
						required_switches.size()
					]
				)
			return
	push_error("Elevator scene name must start with Elevator-One, Elevator-Two, or Elevator-Three.")
