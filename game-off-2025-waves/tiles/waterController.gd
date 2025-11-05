extends TileMapLayer

#waterController-gd
#this class is responsible for the water going up

@export var water_level : float = 1

@onready var height_map: TileMapLayer = $"../heightMap" # defines the height on the tiles - tiles are drawn on top of the walkable tilemaplayer
# height is defines as a cumstom data layer
# it can be 1.00, 1.50, 2.0 and 2,5 
# when it's .5 it a stair tile. might be relevant later

const HEIGHT_LAYER_NAME := "height"
const WATER_TYPE_LAYER_NAME := "water_type"

 # the atlas coordinates for the correct FULL water tile
const WATER_TILE_UP_INDEX : Vector2i = Vector2i(0, 0)
const WATER_TILE_ALL_INDEX : Vector2i = Vector2i(4, 0)
const WATER_TILE_RIGHT_INDEX : Vector2i = Vector2i(2, 0)
const WATER_TILE_LEFT_INDEX : Vector2i = Vector2i(3, 0)




func _ready() -> void:
	#update_water_tiles()
	pass

func _process(_delta: float) -> void:
	#update_water_tiles()
	#print(water_level)
	pass

func update_water_tiles():
	clear() # remove old water tiles before redrawing
	for cell : Vector2i in height_map.get_used_cells():
		var data :TileData = height_map.get_cell_tile_data(cell)
		var cell_height : float = data.get_custom_data(HEIGHT_LAYER_NAME)
		var cell_water_type : String = data.get_custom_data(WATER_TYPE_LAYER_NAME)
		#print(cell_height)
		if cell_height <= water_level:
			_set_water_tile(cell, cell_water_type)

		

func _set_water_tile(cell : Vector2i, water_type : String) -> void:
	match water_type:
		"up": set_cell(cell, 0, WATER_TILE_UP_INDEX)
		"right": set_cell(cell, 0, WATER_TILE_RIGHT_INDEX)
		"left": set_cell(cell, 0, WATER_TILE_LEFT_INDEX)
		"all": set_cell(cell, 0, WATER_TILE_ALL_INDEX)
		"stair": set_cell(cell, 0, WATER_TILE_ALL_INDEX)
		_: printerr("water type not defined")

func _on_v_slider_value_changed(value: float) -> void:
	water_level = value
	#print_debug("water level: ", water_level)
	update_water_tiles()
