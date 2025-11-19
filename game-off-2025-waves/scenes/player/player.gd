extends CharacterBody2D
class_name Player

const MOVESPEED : float = 65

@export var max_speed: float = 65.0
@export var acceleration: float = 500.0
@export var deceleration: float = 1000

@onready var height_map: TileMapLayer = %heightMap
@onready var walkable: TileMapLayer = %walkable

@export var debug_mark_tile_under_player : bool = false
var debug_tile_world_pos: Vector2 = Vector2.ZERO

var current_player_height : float = 1.0
var old_player_height : float = 1.0
var is_on_platform : bool = false

# 2D input direction before isometric transform
var input_dir: Vector2
var move_dir: Vector2

#sfx
@onready var sfx_footstep_grass: AudioStreamPlayer2D = $sfxFootStep/sfx_footstep_grass
@onready var sfx_footstep_stone: AudioStreamPlayer2D = $sfxFootStep/sfx_footstep_stone
const SURFACE_TYPE_TILE_NAME : String = "surface_type"
var footstep_cooldown := 0.0 # don't change - 
var footstep_interval := 0.38 #the interval for howw often steps are played


#var player_pos_node_to_update : Vector2 #used for follow camera's since this object is reparented
#@onready var player_position_node: Node2D

func _ready() -> void:
	get_parent().global_position = global_position #updates wrapper

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("use"):
		Events.player_use.emit()

func _process(_delta: float) -> void:
	#player_position_node.global_position = global_position
	
	if Input.is_action_just_pressed("water_up"):
		move_water(true)
	elif Input.is_action_just_pressed("water_down"):
		move_water(false)
	
	
	#draws the tile under player if export true
	if debug_mark_tile_under_player:
		queue_redraw()
	
	#print("height: ", current_player_height)

func _physics_process(delta: float) -> void:
	_movement(delta)
	_handle_footsteps(delta)
	
	if not is_on_platform: #platform change this bool
		#if player is on platform. height should not be changed by player itself
		_get_height_tile_under_player()
	

func _handle_footsteps(delta: float) -> void:
	# Must be moving AND on the ground
	if velocity.length() > 10.0: # threshold so tiny jitter doesn't trigger
		footstep_cooldown -= delta

		if footstep_cooldown <= 0.0:
			_play_footstep()
			footstep_cooldown = footstep_interval
	else:
		# Reset when not moving so it plays instantly on next step
		footstep_cooldown = 0.0

func _play_footstep() -> void:
	var tile := walkable.get_cell_tile_data(height_map.local_to_map(height_map.to_local(global_position)))
	
	if tile:
		var surface : Variant = tile.get_custom_data(SURFACE_TYPE_TILE_NAME)
		
		if surface == "grass":
			sfx_footstep_grass.play()
		else:
			sfx_footstep_stone.play()
	else: #still play even if data was not found - defaults to stone sfx
		sfx_footstep_stone.play()

func _movement(delta : float) -> void:
	input_dir = Input.get_vector("left", "right", "up", "down")

	if input_dir != Vector2.ZERO:
		var dir_name := _get_direction_name(input_dir)

		match dir_name: #uncomment below for the isometric movement
			"northeast":
				move_dir = Vector2(1, -0.5).normalized()
			"northwest":
				move_dir = Vector2(-1, -0.5).normalized()
			"southeast":
				move_dir = Vector2(1, 0.5).normalized()
			"southwest":
				move_dir = Vector2(-1, 0.5).normalized()
			_:  #top-down directions
				move_dir = input_dir

		velocity = velocity.move_toward(move_dir * max_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)

	move_and_slide()

func _get_height_tile_under_player() -> void:
	if not height_map:
		push_error("height map not defined correctly on player")
		return
	
	# convert player global position to a cell coordinate
	var player_pos_to_check: Vector2 = global_position# + Vector2(0, -3)
	var cell: Vector2i = height_map.local_to_map(height_map.to_local(player_pos_to_check))
	
	# Get the tile's TileData object
	var tile_data: TileData = height_map.get_cell_tile_data(cell)
	if tile_data == null:
		#print("No tile found under player at ", cell)
		return

	var height_value : float = tile_data.get_custom_data("height")
	current_player_height = height_value
	if current_player_height != old_player_height:
		old_player_height = current_player_height
		Events.emit_signal("player_height_changed", current_player_height)
	#var water_type : String = tile_data.get_custom_data("water_type")
	
	#used for debug draw
	debug_tile_world_pos = height_map.map_to_local(cell) #enable if need to se what tile under player is
	#print("height: ", height_value, ", type: ", water_type)
	

func move_water(is_up : bool) -> void:
	Events.emit_signal("requested_water_level_direction", is_up)
	
func _get_direction_name(v: Vector2) -> String:
	# 8-direction classification
	if v.x == 0 and v.y < 0:
		return "north"
	elif v.x == 0 and v.y > 0:
		return "south"
	elif v.x < 0 and v.y == 0:
		return "west"
	elif v.x > 0 and v.y == 0:
		return "east"
	elif v.x > 0 and v.y < 0:
		return "northeast"
	elif v.x < 0 and v.y < 0:
		return "northwest"
	elif v.x > 0 and v.y > 0:
		return "southeast"
	elif v.x < 0 and v.y > 0:
		return "southwest"
	else:
		return "idle"

func _draw() -> void:
	#debug draw tile under player
	if not debug_mark_tile_under_player:
		return

	# Convert world position to player's local space
	var local_pos : Vector2 = to_local(debug_tile_world_pos)

	# Draw isometric diamond (32×16) centered on the tile under the player
	var half_w := 16.0
	var half_h := 8.0
	var points := [
		local_pos + Vector2(0, -half_h),
		local_pos + Vector2(half_w, 0),
		local_pos + Vector2(0, half_h),
		local_pos + Vector2(-half_w, 0)
	]

	draw_polyline(points + [points[0]], Color(1.0, 0.067, 1.0, 0.486), 2.0)
