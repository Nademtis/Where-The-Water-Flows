extends Node2D

var collision_list : Array[TileMapLayer]
@export var debug_show_active_collmap : bool = false # will debug show active coll map. REMEMBBER to turn on the editor debug show all collisions

func _ready() -> void:
	for child in get_children():
		if child is TileMapLayer:
			collision_list.append(child)
			
			if debug_show_active_collmap:
				child.self_modulate = Color(0.0, 0.0, 0.0, 0.0)
				visible = true
			else:
				pass
				child.visible = false
	
	Events.connect("player_height_changed", enable_correct_coll_map)
	enable_correct_coll_map(1.0)

func enable_correct_coll_map(new_player_height : float) -> void:
	var active_index: int = int(floor(new_player_height)) - 1 # minus one since we're going from height to an array index
	#print("should coll map stuff with height: ", new_player_height)

	#enable correct coll map based on palyer height
	for i in range(collision_list.size()):
		var coll_map: TileMapLayer = collision_list[i]
		if i == active_index:
			#coll_map.visible = true
			coll_map.collision_enabled = true
		else:
			#coll_map.visible = false
			coll_map.collision_enabled = false
	
