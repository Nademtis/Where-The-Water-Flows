extends TileMapLayer
#waterController
#this class is responsible for the water going up and down

@export var water_level : float = 1.0 # should start as 1.0
var previous_level : float = 1.0
@export var water_animation_wait_time : float = 0.001

@onready var height_map: TileMapLayer = $"../heightMap" # this defines the height on the tiles - tiles are drawn on top of the walkable tilemaplayer
# height and water_type is defines as a cumstom data layer in height_map

var sorted_cells : Array[Vector2i] = []

const HEIGHT_LAYER_NAME := "height"
const WATER_TYPE_LAYER_NAME := "water_type"

#region water animation
 # the atlas coordinates for the correct FULL water tile
const WATER_TILE_UP : Vector2i = Vector2i(0, 0)
const WATER_TILE_RIGHT : Vector2i = Vector2i(2, 0)
const WATER_TILE_LEFT : Vector2i = Vector2i(3, 0)
const WATER_TILE_ALL : Vector2i = Vector2i(4, 0)
const WATER_TILE_LEFT_CORNER : Vector2i = Vector2i(5, 0)
const WATER_TILE_RIGHT_CORNER : Vector2i = Vector2i(6, 0)

# the atlas coordinates for the correct FULL LOWER water tile
const WATER_LOWER_TILE_RIGHT : Vector2i = Vector2i(7, 0)
const WATER_LOWER_TILE_LEFT : Vector2i = Vector2i(8, 0)
const WATER_LOWER_TILE_LEFT_CORNER : Vector2i = Vector2i(9, 0)
const WATER_LOWER_TILE_RIGHT_CORNER : Vector2i = Vector2i(10, 0)


#corner animation tiles
#const WATER_TILE_UP_ANIMATION_INDEX : Vector2i = Vector2i(0, 0)
const WATER_TILE_RIGHT_ANIMATION : Vector2i = Vector2i(0, 1)
const WATER_TILE_LEFT_ANIMATION : Vector2i = Vector2i(0, 2)
const WATER_TILE_ALL_ANIMATION : Vector2i = Vector2i(0, 3)
const WATER_TILE_LEFT_CORNER_ANIMATION : Vector2i = Vector2i(0, 4)
const WATER_TILE_RIGHT_CORNER_ANIMATION : Vector2i = Vector2i(0, 5)
#endregion water animation


func _ready() -> void:
	var cells : Array[Vector2i] = height_map.get_used_cells()
	cells.sort_custom(func(a : Vector2i, b: Vector2i) -> bool:  return a.y > b.y)
	sorted_cells = cells
	
	update_water_tiles()
	Events.connect("water_level_direction", _update_water_level)

func _update_water_level(going_up : bool) -> void:
	previous_level = water_level
	if going_up:
		water_level += 1
	else:
		water_level -= 1
	
	water_level = clamp(water_level, 1.0, 5.0) #TODO should probably not be max 5
	Events.emit_signal("water_level_changed", water_level)
	update_water_tiles()

func update_water_tiles() -> void:
	var last_y : float = INF
	var going_up : bool = water_level > previous_level
	var count : int = sorted_cells.size()

	if going_up:
		for i in range(count):  # iterate bottom -> top (water going up)
			var cell : Vector2i = sorted_cells[i]
			await _process_cell(cell, last_y, going_up)
	else: # water going down
		for i in range(count - 1, -1, -1): # iterate top -> bottom (water going down)
			var cell : Vector2i = sorted_cells[i]
			await _process_cell(cell, last_y, going_up)

func _process_cell(cell: Vector2i, last_y: float, going_up: bool) -> void:
	var data : TileData = height_map.get_cell_tile_data(cell)
	if data == null:
		return

	var cell_height : float = data.get_custom_data(HEIGHT_LAYER_NAME)
	var cell_water_type : String = data.get_custom_data(WATER_TYPE_LAYER_NAME)

	if going_up:
		if cell_height < water_level and cell_height >= previous_level:
			_set_full_water_tile(cell, cell_water_type)
			if cell.y < last_y and cell_water_type == "up":
				last_y = cell.y
				await get_tree().create_timer(water_animation_wait_time, true, true).timeout
		elif cell_height == water_level:
			_set_animation_corner_water_tile(cell, cell_water_type)
	else:
		if cell_height > water_level and cell_height <= previous_level:
			set_cell(cell, -1)
			if cell.y < last_y and cell_water_type == "up":
				last_y = cell.y
				await get_tree().create_timer(water_animation_wait_time, true, true).timeout
		elif cell_height == water_level:
			_set_animation_corner_water_tile(cell, cell_water_type)


func _set_full_water_tile(cell : Vector2i, water_type : String) -> void:
	match water_type:
		"up": set_cell(cell, 0, WATER_TILE_UP)
		"right": set_cell(cell, 0, WATER_TILE_RIGHT)
		"left": set_cell(cell, 0, WATER_TILE_LEFT)
		"all": set_cell(cell, 0, WATER_TILE_ALL)
		"stair": set_cell(cell, 0, WATER_TILE_ALL)
		"left_corner": set_cell(cell, 0, WATER_TILE_LEFT_CORNER)
		"right_corner": set_cell(cell, 0, WATER_TILE_RIGHT_CORNER)
		"lower_right_corner": set_cell(cell, 0, WATER_LOWER_TILE_RIGHT_CORNER)
		"lower_left_corner": set_cell(cell, 0, WATER_LOWER_TILE_LEFT_CORNER)
		"lower_right": set_cell(cell, 0, WATER_LOWER_TILE_RIGHT)
		"lower_left": set_cell(cell, 0, WATER_LOWER_TILE_LEFT)
		_: printerr("water type not defined")
		
func _set_animation_corner_water_tile(cell : Vector2i, water_type : String) -> void:
	match water_type:
		"up": pass
		"all": set_cell(cell, 0, WATER_TILE_ALL_ANIMATION)
		"stair": set_cell(cell, 0, WATER_TILE_ALL_ANIMATION)
		"right", "lower_right": set_cell(cell, 0, WATER_TILE_RIGHT_ANIMATION)
		"left", "lower_left": set_cell(cell, 0, WATER_TILE_LEFT_ANIMATION)
		"left_corner", "lower_left_corner": set_cell(cell, 0, WATER_TILE_LEFT_CORNER_ANIMATION)
		"right_corner", "lower_right_corner": set_cell(cell, 0, WATER_TILE_RIGHT_CORNER_ANIMATION)
		_: printerr("water type not defined")

func _on_v_slider_value_changed(value: float) -> void:
	water_level = value
	update_water_tiles()
