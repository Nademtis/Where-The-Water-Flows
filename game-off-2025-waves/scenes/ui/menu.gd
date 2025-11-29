extends Control

const master_bus_name : String = "Master"
const music_bus_name : String = "Player_Music"
const sfx_bus_name : String = "Player_SFX"
const Ambience_bus_name : String = "Player_Ambience"

@onready var master_volume_slider: HSlider = $CenterContainer/VBoxContainer/VBoxContainer/MasterVolumeSlider
@onready var music_volume_slider: HSlider = $CenterContainer/VBoxContainer/VBoxContainer/MusicVolumeSlider
@onready var sfx_volume_slider: HSlider = $CenterContainer/VBoxContainer/VBoxContainer/SFXVolumeSlider
@onready var ambience_slider: HSlider = $CenterContainer/VBoxContainer/VBoxContainer/AmbienceSlider


func _ready() -> void:
	pass
	#var tree : String = self.get_tree_string_pretty()
	#print(tree)
	#print(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(master_bus_name)))
	#set_sliders()
	
func _on_restartlevel_button_button_down() -> void:
	Events.emit_signal("restart_current_level")
	pass # Replace with function body.




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
