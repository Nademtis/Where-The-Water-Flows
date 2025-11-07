extends TileMapLayer
#waterController
#this class is responsible for the water going up and down

@export var water_level : float = 1.0 # should start as 1.0

@onready var height_map: TileMapLayer = $"../heightMap" # this defines the height on the tiles - tiles are drawn on top of the walkable tilemaplayer
# height and water_type is defines as a cumstom data layer in height_map

const HEIGHT_LAYER_NAME := "height"
const WATER_TYPE_LAYER_NAME := "water_type"

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

var sorted_cells : Array[Vector2i] = []

func _ready() -> void:
	var cells : Array[Vector2i] = height_map.get_used_cells()
	cells.sort_custom(func(a, b): return a.y > b.y)
	sorted_cells = cells
	
	update_water_tiles()
	Events.connect("water_level_direction", _update_water_level)
	pass

func _process(_delta: float) -> void:
	pass

func _update_water_level(going_up : bool) -> void:
	if going_up:
		water_level += 1
	else:
		water_level -= 1
	
	water_level = clamp(water_level, 1.0, 5.0)
	update_water_tiles()

func update_water_tiles():
	var last_y := INF
	clear()
	for cell : Vector2i in sorted_cells:
		var data : TileData = height_map.get_cell_tile_data(cell)
		var cell_height : float = data.get_custom_data(HEIGHT_LAYER_NAME)
		var cell_water_type : String = data.get_custom_data(WATER_TYPE_LAYER_NAME)

		#don't anim if water level is only 1, since that's the buttom
		if water_level == 1.0:
			if cell_height == 1: _set_animation_corner_water_tile(cell, cell_water_type)
		else:
			if cell_height < water_level:
				_set_full_water_tile(cell, cell_water_type)
				if cell.y < last_y:
					last_y = cell.y
					await get_tree().create_timer(0.05).timeout
			if cell_height == water_level: _set_animation_corner_water_tile(cell, cell_water_type)
		
		#wait for the water when stepping up in level


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
