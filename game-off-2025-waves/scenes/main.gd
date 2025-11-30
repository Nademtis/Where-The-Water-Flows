extends Node2D

@onready var level_container: Node2D = $levelContainer
@onready var animation_player: AnimationPlayer = $SceneTransition/AnimationPlayer

#const FIRST_LEVEL_PATH: String = "res://levels/level_playground.tscn"
#const FIRST_LEVEL_PATH: String = "res://levels/level_template.tscn"

const FIRST_LEVEL_PATH: String = "res://levels/level_1.tscn"
@onready var level_indicator: Label = $CanvasLayer/levelIndicator

@onready var focus_menu: CanvasLayer = $AudioManager/focusMenu
@onready var menu_canvas_layer: CanvasLayer = $menuCanvasLayer
@onready var reccomended: CanvasLayer = $Reccomended


var next_level_path: String
var current_level_path: String

var showing_menu : bool = false
@onready var menu_controller: Control = $menuCanvasLayer/Control


func _ready() -> void:
	next_level_path = FIRST_LEVEL_PATH
	Events.connect("load_new_level", start_new_level)
	Events.connect("restart_current_level" , restart_level)
	
	_setup_new_level() # skip the start_new_level since we don't want to fade to black. it's already black
	#print(get_tree_string_pretty())
	get_window().focus_entered.connect(_on_window_focus_entered)
	get_window().focus_exited.connect(_on_window_focus_exited)
	Events.emit_signal("player_freeze", false)

func start_new_level(path: String) -> void: # should be called by elevator object
	next_level_path = path
	animation_player.play("fade_to_black")
	remove_active_cam()

func _player_can_move_again() -> void:
	Events.emit_signal("player_freeze", true)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_to_black":
		_setup_new_level()
	elif anim_name == "reccomended":
		reccomended.queue_free()
		
		
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
	level_indicator.text = next_level_path
	_unmute_sfx_temporarily()
	
	current_level_path = next_level_path
	
	#menu stuff
	menu_canvas_layer.visible = false
	showing_menu = false

func restart_level() -> void:
	start_new_level(current_level_path)

func _unmute_sfx_temporarily() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	GameStats.SFX_allowed = true

func remove_active_cam() -> void:
	var list := PhantomCameraManager.get_phantom_camera_2ds()
	if list:
		for cam in list:
			cam.priority = 0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		menu()

func menu() ->  void:
	showing_menu = !showing_menu
	
	if showing_menu:
		menu_canvas_layer.visible = true
		menu_controller.play_menu_sfx(true)
	else:
		menu_canvas_layer.visible = false
		menu_controller.play_menu_sfx(false)
		
	
func _on_window_focus_entered() -> void:
	focus_menu.visible = false

func _on_window_focus_exited() -> void:
	focus_menu.visible = true
