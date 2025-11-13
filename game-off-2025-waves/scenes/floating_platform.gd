extends Node2D
class_name FloatingPlatform

@onready var floatable_component: FloatableComponent = $FloatableComponent
@export var float_speed: float = 3.5 #higher  = faster
@export var start_water_level: int = 1  #used to replace the platforms position to align with water_level

@export var coll_map : TileMapLayer
var coll_map_position : Dictionary = {}
var tile_to_place_index : Vector2i = Vector2i(0,0)

var last_y: float
var player: Player = null

var current_player_height: float = 1

func _ready() -> void:
	if not coll_map:
		push_error("coll map not defined on platform")
	else: #save the position of every tile correctly in the tilemap based on the int height as key and Vector2i for position
		coll_map_position.clear()
		var used_cells: Array[Vector2i] = coll_map.get_used_cells()
		for cell in used_cells:
			var height_value: int = coll_map.get_cell_tile_data(cell).get_custom_data("height")
			coll_map_position[cell] = height_value

		print(coll_map_position)
	enable_correct_coll_tiles(1)
	floatable_component.component_changed_level.connect(change_player_height)
	Events.connect("player_height_changed", func(new_height: float) -> void:
		current_player_height = new_height)

func _process(_delta: float) -> void:
	var diff_y := global_position.y - last_y
	last_y = global_position.y

	if player:
		player.global_position.y += diff_y

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if abs(body.current_player_height - floatable_component.current_level) <= 0.5:
			player = body
			var parent: Node2D = get_parent()
			body.call_deferred("reparent", parent, true)
			body.z_index = 0
			body.is_on_platform = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == player:
		body.z_index = 1
		body.is_on_platform = false
		player = null

func change_player_height(new_height : float) -> void:
	enable_correct_coll_tiles(new_height)
	if player: # only change player height if player on platform
		player.current_player_height = new_height
		await get_tree().create_timer(0.1).timeout
		Events.emit_signal("player_height_changed", player.current_player_height)

func enable_correct_coll_tiles(new_height: float) -> void:
	var new_int_height: int = int(new_height)
	#print("from platform, disable tiles with height:", new_int_height)

	if not coll_map:
		return

	# 1. Fill all tiles first
	coll_map.clear()
	for cell: Vector2i in coll_map_position.keys():
		coll_map.set_cell(cell, 0, tile_to_place_index)

	# 2. Then remove tiles with the same height as the current level
	var removed_tiles: Array[Vector2i] = []

	for cell: Vector2i in coll_map_position.keys():
		if coll_map_position[cell] == new_int_height && current_player_height == new_int_height:
			coll_map.erase_cell(cell)
			removed_tiles.append(cell)

	#if removed_tiles.is_empty():
		#print("No tiles removed for height:", new_int_height)
	#else:
		#print("Removed tiles for height %d: %s" % [new_int_height, str(removed_tiles)])
