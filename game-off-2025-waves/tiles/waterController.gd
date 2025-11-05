@tool
extends TileMapLayer

#waterController-gd
#this class is responsible for the water going up

@export var water_level : float = 1

@onready var height_map: TileMapLayer = $"../heightMap" # defines the height on the tiles - tiles are drawn on top of the walkable tilemaplayer
# height is defines as a cumstom data layer
# it can be 1.00, 1.50, 2.0 and 2,5 
# when it's .5 it a stair tile. might be relevant later

const HEIGHT_LAYER_NAME := "height" # name of your custom data layer

const WATER_TILE_INDEX : Vector2i = Vector2i(0, 1) # the atlas coordinates for the water tile

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
		#print(cell_height)
		if cell_height <= water_level:
			#print("water")
			set_cell(cell, 1, WATER_TILE_INDEX)
		

func _on_v_slider_value_changed(value: float) -> void:
	water_level = value
	#print_debug("water level: ", water_level)
	update_water_tiles()
