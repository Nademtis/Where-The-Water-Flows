extends Item
class_name FloatableItem

@export var start_height_level: int
var current_height_level: int
var current_water_level : int
var float_speed: float = 3.5

@onready var water_sprite: Sprite2D = $water

@export var bounce_height: float = 1.0
@export var bounce_speed: float = 1
var bounce_tween: Tween

@onready var height_map: TileMapLayer = %heightMap

@export var float_duration : float = 0.5
var tween : Tween

func _ready() -> void:
	Events.connect("confirmed_new_water_level_direction", check_for_floating)
	current_height_level = start_height_level
	current_water_level = 1 #might be a problem if some levels start with higher water level

func check_for_floating(went_up: bool) -> void:
	if went_up:
		current_water_level += 1
	else:
		current_water_level -= 1

	if get_parent().is_in_group("player"):
		return

	#water go up
	if went_up:
		if current_water_level > current_height_level:
			current_height_level += 1
			_move_item(global_position + Vector2(0, -16), true)
			_disable_collisions(true)
			return

	#water go down
	if not went_up:
		if current_water_level >= start_height_level:
			current_height_level -= 1
			_move_item(global_position + Vector2(0, 16), false)
		
		# item landed on ground
		if current_water_level == start_height_level:
			_disable_collisions(false)
			_stop_bounce()
			water_sprite.visible = false

func drop(new_pos: Vector2) -> void:
	super.drop(new_pos)
	_set_height_under_item(new_pos)

func _move_item(new_pos : Vector2, go_up: bool) -> void:
	if tween and tween.is_running():
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(self, "global_position", new_pos, float_duration).set_ease(Tween.EASE_IN)
	if go_up:
		tween.finished.connect(_start_bounce)
	else:
		_disable_collisions(false)
		
	
func _start_bounce() -> void:
	# cancel old tween
	if bounce_tween and bounce_tween.is_running():
		bounce_tween.kill()

	var start_y := global_position.y
	var up_y := start_y - bounce_height
	var down_y := start_y + bounce_height

	# Tween that loops up & down forever
	bounce_tween = create_tween().set_loops()

	bounce_tween.tween_property(self, "global_position:y", up_y, bounce_speed)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)

	bounce_tween.tween_property(self, "global_position:y", down_y, bounce_speed)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
	
func _stop_bounce() -> void:
	if bounce_tween and bounce_tween.is_running():
		bounce_tween.kill()

func _set_height_under_item(new_pos: Vector2) -> void:
	if not height_map:
		push_error("height map not defined correctly on player")
		return
	
	var cell: Vector2i = height_map.local_to_map(height_map.to_local(new_pos))
	
	var tile_data: TileData = height_map.get_cell_tile_data(cell)
	if tile_data == null:
		print("No tile found under item at ", cell)
		return

	var height_value : float = tile_data.get_custom_data("height")
	print("new item height is: ", height_value as int)
	current_height_level = height_value as int
	start_height_level = height_value as int
