extends Node2D

@onready var level_container: Node2D = $levelContainer
@onready var animation_player: AnimationPlayer = $SceneTransition/AnimationPlayer

#const FIRST_LEVEL_PATH: String = "res://levels/level_playground.tscn"
#const FIRST_LEVEL_PATH: String = "res://levels/level_template.tscn"

const FIRST_LEVEL_PATH: String = "res://levels/level_6.tscn"


var next_level_path: String
var current_level_path: String


func _ready() -> void:
	next_level_path = FIRST_LEVEL_PATH
	Events.connect("load_new_level", start_new_level)
	
	_setup_new_level() # skip the start_new_level since we don't want to fade to black. it's already black
	#print(get_tree_string_pretty())

func start_new_level(path: String) -> void: # should be called by elevator object
	next_level_path = path
	animation_player.play("fade_to_black")
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_to_black":
		_setup_new_level()
		
func _setup_new_level() -> void:
	GameStats.SFX_allowed = false
	
	for child in level_container.get_children():
		child.queue_free()
		
	# Load new level
	var level_scene: PackedScene = load(next_level_path) as PackedScene
	if not level_scene:
		push_error("Failed to load level: " + next_level_path)
		return

	var new_level_scene : PackedScene = load(next_level_path)
	var new_level_instance : Node2D = new_level_scene.instantiate()
	level_container.add_child(new_level_instance)

	Events.emit_signal("new_level_done_loading")
	animation_player.play("fade_out")
	
	_unmute_sfx_temporarily()
	
	#var tree : String = get_tree_string_pretty()
	#print(tree)

func _unmute_sfx_temporarily() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	GameStats.SFX_allowed = true
