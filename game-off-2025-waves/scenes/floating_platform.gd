extends Node2D
class_name FloatingPlatform

@onready var floatable_component: FloatableComponent = $FloatableComponent
@export var float_speed: float = 3.5 #higher  = faster
@export var start_water_level: int = 1  #used to replace the platforms position to align with water_level

@export var coll_map : TileMapLayer
var coll_map_position : Dictionary = {}
var tile_to_place_index : Vector2i = Vector2i(0,0)

@onready var local_collision_tile_map: TileMapLayer = $LocalCollisionTileMap
@export var where_to_remove_col : Array[HeightDirections] = []
var local_coll_tile_to_place := Vector2i(0, 0)
enum Direction { NW, NE, SE, SW }

var NW_coll_index_1 := Vector2i(-1,-2)
var NW_coll_index_2 := Vector2i(-2,-1)

var NE_coll_index_1 := Vector2i(0,-2)
var NE_coll_index_2 := Vector2i(0,-1)

var SE_coll_index_1 := Vector2i(0, 1)
var SE_coll_index_2 := Vector2i(0, 2)

var SW_coll_index_1 := Vector2i(-1, 2)
var SW_coll_index_2 := Vector2i(-2, 1)

var last_y: float
var player: Player = null

var current_player_height: int = 1

#sfx
@onready var player_floating_platform_adjust_height_sfx: AudioStreamPlayer = $playerFloatingPlatformAdjustHeightSFX

func _ready() -> void:
	local_collision_tile_map.collision_enabled = false #set false since only visible when player is on
	#local_collision_tile_map.modulate = Color("ffffff00")
	_update_local_collision(1)
	
	if not coll_map:
		push_error("coll map not defined on platform")
	else: #save the position of every tile correctly in the tilemap based on the int height as key and Vector2i for position
		coll_map.visible = false
		coll_map_position.clear()
		var used_cells: Array[Vector2i] = coll_map.get_used_cells()
		for cell in used_cells:
			var height_value: int = coll_map.get_cell_tile_data(cell).get_custom_data("height")
			coll_map_position[cell] = height_value

	enable_correct_coll_tiles(1)
	floatable_component.component_changed_level.connect(change_player_height)
	Events.connect("player_height_changed", func(new_height: float) -> void:
		@warning_ignore("narrowing_conversion")
		current_player_height = new_height
		enable_correct_coll_tiles(current_player_height)
		
		)
		
		
func _process(_delta: float) -> void:
	var diff_y := global_position.y - last_y
	last_y = global_position.y

	if player:
		player.global_position.y += diff_y

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if abs(body.current_player_height - floatable_component.current_level) <= 0.5:
			player = body

			var player_wrapper : Node2D = body.get_parent()
			var old_player_pos : Vector2 = body.global_position
			
			player_wrapper.global_position = get_parent().global_position
			body.global_position = old_player_pos
		
			#to be behind some walls
			player_wrapper.z_index = 0
			body.is_on_platform = true
			
			local_collision_tile_map.collision_enabled = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == player:
		var player_wrapper : Node2D = body.get_parent()
		var old_player_pos : Vector2 = body.global_position
		player_wrapper.z_index = 1
		player_wrapper.global_position = body.global_position
		body.global_position = old_player_pos
		
		body.is_on_platform = false
		local_collision_tile_map.collision_enabled = false
		
		player = null
	
func _refresh_camera_target(player_ref: Node2D) -> void:
	var phantom_camera_host : PhantomCameraHost = PhantomCameraManager.get_phantom_camera_hosts()[0]
	var pcam := phantom_camera_host._active_pcam_2d
	if pcam == null:
		print("no active phantom camera found")
		return

	#reassign camera target since player is reparented in floating platform
	pcam.follow_target = null
	pcam.follow_target = player_ref

func _update_local_collision(height: float) -> void:
	var int_height := int(height)
	var hd: HeightDirections = null
	for entry in where_to_remove_col:
		if entry.height == int_height:
			hd = entry
			break
	if hd == null:
		_paint_local_coll_tiles()
		return

	var remove_set := hd.directions
	for d : Direction in Direction.values():
		match d:
			Direction.NW:
				_handle_dir(remove_set, d, NW_coll_index_1, NW_coll_index_2)
			Direction.NE:
				_handle_dir(remove_set, d, NE_coll_index_1, NE_coll_index_2)
			Direction.SE:
				_handle_dir(remove_set, d, SE_coll_index_1, SE_coll_index_2)
			Direction.SW:
				_handle_dir(remove_set, d, SW_coll_index_1, SW_coll_index_2)

func _handle_dir(remove_set : Array[int], dir : Direction, idx1: Vector2i, idx2: Vector2i) -> void:
	if dir in remove_set:
		local_collision_tile_map.set_cell(idx1, -1)
		local_collision_tile_map.set_cell(idx2, -1)
	else:
		_repaint_if_missing(idx1)
		_repaint_if_missing(idx2)

func _repaint_if_missing(cell: Vector2i) -> void:
	var existing := local_collision_tile_map.get_cell_source_id(cell)
	if existing == -1:
		local_collision_tile_map.set_cell(cell, 0, local_coll_tile_to_place) 

func _paint_local_coll_tiles() -> void:
	for d : Direction in Direction.values():
		match d:
			Direction.NW:
				_handle_dir([], d, NW_coll_index_1, NW_coll_index_2)
			Direction.NE:
				_handle_dir([], d, NE_coll_index_1, NE_coll_index_2)
			Direction.SE:
				_handle_dir([], d, SE_coll_index_1, SE_coll_index_2)
			Direction.SW:
				_handle_dir([], d, SW_coll_index_1, SW_coll_index_2)



func change_player_height(new_height : float) -> void:
	enable_correct_coll_tiles(new_height)
	if player: # only change player height if player on platform
		player.current_player_height = new_height
		player_floating_platform_adjust_height_sfx.play()
		Events.emit_signal("player_height_changed", player.current_player_height)

func enable_correct_coll_tiles(_new_height: float) -> void:
	if player:
		return
		
	if not coll_map:
		push_error("coll map not defined")
		return
	coll_map.clear()
	
	for cell: Vector2i in coll_map_position.keys():
		if coll_map_position[cell] == current_player_height and floatable_component.current_level != current_player_height:
			coll_map.set_cell(cell, 0, tile_to_place_index)


func _on_floatable_component_component_changed_level(new_level: float) -> void:
	_update_local_collision(new_level)
