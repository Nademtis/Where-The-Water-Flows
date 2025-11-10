extends CharacterBody2D

const MOVESPEED : float = 65

@export var max_speed: float = 65.0
@export var acceleration: float = 400.0
@export var deceleration: float = 1000

@onready var height_map: TileMapLayer = %heightMap



# 2D input direction before isometric transform
var input_dir: Vector2
#var iso_dir: Vector2
var move_dir: Vector2

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("water_up"):
		move_water(true)
	elif Input.is_action_just_pressed("water_down"):
		move_water(false)


func _physics_process(delta: float) -> void:
	input_dir = Input.get_vector("left", "right", "up", "down")

	if input_dir != Vector2.ZERO:
		var dir_name := _get_direction_name(input_dir)

		match dir_name: #uncomment below for the isometric movement
			#"northeast":
				#move_dir = Vector2(1, -0.5).normalized()
			#"northwest":
				#move_dir = Vector2(-1, -0.5).normalized()
			#"southeast":
				#move_dir = Vector2(1, 0.5).normalized()
			#"southwest":
				#move_dir = Vector2(-1, 0.5).normalized()
			_:  #top-down directions
				move_dir = input_dir

		velocity = velocity.move_toward(move_dir * max_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)

	move_and_slide()
	_get_height_tile_under_player()
	
func _get_height_tile_under_player() -> void:
	if not height_map:
		push_error("height map not defined correctly on player")
		return
	
	# Convert player global position to a cell coordinate
	var cell: Vector2i = height_map.local_to_map(height_map.to_local(global_position))
	
	# Get the tile's TileData object
	var tile_data: TileData = height_map.get_cell_tile_data(cell)
	if tile_data == null:
		print("No tile found under player at ", cell)
		return

	# Read custom data layers (make sure these names match your TileSet setup)
	var height_value : float = tile_data.get_custom_data("height")
	var water_type : String = tile_data.get_custom_data("water_type")
	
	print("height: ", height_value, ", type: ", water_type)


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
