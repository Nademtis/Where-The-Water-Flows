extends TileMapLayer

#waterController-gd
#this class is responsible for the water going up

@export var water_level : float = 2.0

@onready var height_map: TileMapLayer = $"../heightMap" # defines the height on the tiles - tiles are drawn on top of the walkable tilemaplayer
# height is defines as a cumstom data layer
# it can be 1.00, 1.50, 2.0 and 2,5 
# when it's .5 it a stair tile. might be relevant later

const HEIGHT_LAYER_NAME := "height"
const WATER_TYPE_LAYER_NAME := "water_type"

 # the atlas coordinates for the correct FULL water tile
const WATER_TILE_UP : Vector2i = Vector2i(0, 0)
const WATER_TILE_RIGHT : Vector2i = Vector2i(2, 0)
const WATER_TILE_LEFT : Vector2i = Vector2i(3, 0)
const WATER_TILE_ALL : Vector2i = Vector2i(4, 0)
const WATER_TILE_LEFT_CORNER : Vector2i = Vector2i(5, 0)
const WATER_TILE_RIGHT_CORNER : Vector2i = Vector2i(6, 0)

#corner animation tiles
#const WATER_TILE_UP_ANIMATION_INDEX : Vector2i = Vector2i(0, 0)
const WATER_TILE_RIGHT_ANIMATION : Vector2i = Vector2i(0, 1)
const WATER_TILE_LEFT_ANIMATION : Vector2i = Vector2i(0, 2)
const WATER_TILE_ALL_ANIMATION : Vector2i = Vector2i(0, 3)
const WATER_TILE_LEFT_CORNER_ANIMATION : Vector2i = Vector2i(0, 4)
const WATER_TILE_RIGHT_CORNER_ANIMATION : Vector2i = Vector2i(0, 5)


func _ready() -> void:
	update_water_tiles()
	pass

func _process(_delta: float) -> void:
	#update_water_tiles()
	#print(water_level)
	pass

func update_water_tiles():
	clear()
	print_debug("water level: ", water_level)
	for cell : Vector2i in height_map.get_used_cells():
		var data : TileData = height_map.get_cell_tile_data(cell)
		var cell_height : float = data.get_custom_data(HEIGHT_LAYER_NAME)
		var cell_water_type : String = data.get_custom_data(WATER_TYPE_LAYER_NAME)

		if water_level == 1.0:
			if cell_height == 1: _set_animation_corner_water_tile(cell, cell_water_type)
		else:
			if cell_height < water_level: _set_full_water_tile(cell, cell_water_type)
			if cell_height == water_level: _set_animation_corner_water_tile(cell, cell_water_type)

func _set_full_water_tile(cell : Vector2i, water_type : String) -> void:
	match water_type:
		"up": set_cell(cell, 0, WATER_TILE_UP)
		"right": set_cell(cell, 0, WATER_TILE_RIGHT)
		"left": set_cell(cell, 0, WATER_TILE_LEFT)
		"all": set_cell(cell, 0, WATER_TILE_ALL)
		"stair": set_cell(cell, 0, WATER_TILE_ALL)
		"left_corner": set_cell(cell, 0, WATER_TILE_LEFT_CORNER)
		"right_corner": set_cell(cell, 0, WATER_TILE_RIGHT_CORNER)
		_: printerr("water type not defined")
		
func _set_animation_corner_water_tile(cell : Vector2i, water_type : String) -> void:
	match water_type:
		"up": pass
		"right": set_cell(cell, 0, WATER_TILE_RIGHT_ANIMATION)
		"left": set_cell(cell, 0, WATER_TILE_LEFT_ANIMATION)
		"all": set_cell(cell, 0, WATER_TILE_ALL_ANIMATION)
		"stair": set_cell(cell, 0, WATER_TILE_ALL_ANIMATION)
		"left_corner": set_cell(cell, 0, WATER_TILE_LEFT_CORNER_ANIMATION)
		"right_corner": set_cell(cell, 0, WATER_TILE_RIGHT_CORNER_ANIMATION)
		_: printerr("water type not defined")

func _on_v_slider_value_changed(value: float) -> void:
	water_level = value
	#print_debug("water level: ", water_level)
	update_water_tiles()
