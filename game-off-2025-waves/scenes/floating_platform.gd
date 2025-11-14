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

var current_player_height: int = 1

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
			var parent := get_parent()

			body.visible = false
			call_deferred("_deferred_reparent", body, parent)

func _deferred_reparent(body: Node2D, new_parent: Node2D) -> void:
	# reparent while keeping global transform to avoid teleport/flicker
	body.reparent(new_parent, true)

	# restore z_index, flags, and reveal player
	body.z_index = 0
	body.is_on_platform = true
	body.visible = true

	# refresh camera follow target
	_refresh_camera_target(body)
	
	
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == player:
		body.z_index = 1
		body.is_on_platform = false
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

func change_player_height(new_height : float) -> void:
	enable_correct_coll_tiles(new_height)
	if player: # only change player height if player on platform
		player.current_player_height = new_height
		await get_tree().create_timer(0.1).timeout
		Events.emit_signal("player_height_changed", player.current_player_height)

func enable_correct_coll_tiles(new_height: float) -> void:
	if player: # if player is standing on platform. don't change the coll tiles
		return
		
	var _new_int_height: int = int(new_height)

	if not coll_map:
		return
	coll_map.clear()
	
	for cell: Vector2i in coll_map_position.keys():
		if coll_map_position[cell] == current_player_height and floatable_component.current_level != current_player_height:
			coll_map.set_cell(cell, 0, tile_to_place_index)
