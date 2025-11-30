extends Control

const master_bus_name : String = "Master"
const music_bus_name : String = "Player_Music"
const sfx_bus_name : String = "Player_SFX"
const Ambience_bus_name : String = "Player_Ambience"

@onready var master_volume_slider: HSlider = $CenterContainer/VBoxContainer/VBoxContainer/MasterVolumeSlider
@onready var music_volume_slider: HSlider = $CenterContainer/VBoxContainer/VBoxContainer/MusicVolumeSlider
@onready var sfx_volume_slider: HSlider = $CenterContainer/VBoxContainer/VBoxContainer/SFXVolumeSlider
@onready var ambience_slider: HSlider = $CenterContainer/VBoxContainer/VBoxContainer/AmbienceSlider

#sfx
@onready var open_menu_sfx: AudioStreamPlayer = $openMenuSFX
@onready var close_menu_sfx: AudioStreamPlayer = $closeMenuSFX
@onready var click_sfx: AudioStreamPlayer = $clickSFX
@onready var hover_sfx: AudioStreamPlayer = $hoverSFX
@onready var let_go_sfx: AudioStreamPlayer = $letGoSfx

@onready var restartlevel_button: Button = $CenterContainer/VBoxContainer/VBoxContainer/RestartlevelButton


func _ready() -> void:
	master_volume_slider.connect("drag_started", set_slider_click)
	master_volume_slider.connect("mouse_entered", set_slider_hover)
	master_volume_slider.connect("drag_ended", set_slider_let_go)
	
	music_volume_slider.connect("drag_started", set_slider_click)
	music_volume_slider.connect("mouse_entered", set_slider_hover)
	music_volume_slider.connect("drag_ended", set_slider_let_go)
	
	sfx_volume_slider.connect("drag_started", set_slider_click)
	sfx_volume_slider.connect("mouse_entered", set_slider_hover)
	sfx_volume_slider.connect("drag_ended", set_slider_let_go)
	
	ambience_slider.connect("drag_started", set_slider_click)
	ambience_slider.connect("mouse_entered", set_slider_hover)
	ambience_slider.connect("drag_ended", set_slider_let_go)
	
	restartlevel_button.connect("mouse_entered", set_slider_hover)
	
	#var tree : String = self.get_tree_string_pretty()
	#print(tree)
	#print(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(master_bus_name)))
	#set_sliders()


func play_menu_sfx(is_active : bool) -> void:
	if is_active:
		open_menu_sfx.play()
		print("played open menu sfx")
		
	else:
		close_menu_sfx.play()
		print("played close menu sfx")
		
		

func _on_restartlevel_button_button_down() -> void:
	set_slider_click()
	Events.emit_signal("restart_current_level")

func _on_master_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(master_bus_name), linear_to_db(value))
	

func _on_music_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(music_bus_name), linear_to_db(value))



func _on_sfx_volume_slider_value_changed(value: float) -> void:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index(sfx_bus_name), linear_to_db(value))



func _on_ambience_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(Ambience_bus_name), linear_to_db(value))


func set_sliders() ->  void:
	master_volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(master_bus_name)))
	print(master_volume_slider.value)

	music_volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(music_bus_name)))
	print(music_volume_slider.value)

	sfx_volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(sfx_bus_name)))
	print(sfx_volume_slider.value)

	ambience_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(Ambience_bus_name)))
	print(ambience_slider.value)

func set_slider_click() -> void:
	#print("slider focus entered: ", slider)
	click_sfx.play()
	pass

func set_slider_hover() -> void:
	#print("slider hover: ", slider)
	hover_sfx.play()
	pass

func set_slider_let_go(_value_changed : bool) -> void:
	#print("slider let go: ", slider)
	let_go_sfx.play()
	pass
