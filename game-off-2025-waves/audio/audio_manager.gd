extends Node

@onready var music_intro: AudioStreamPlayer = $musicIntro
@onready var music_loop: AudioStreamPlayer = $musicLoop
@onready var player_floating_platform_adjust_height_sfx: AudioStreamPlayer = $playerFloatingPlatformAdjustHeightSFX


func _ready() -> void:
	music_intro.play(0)
	Events.connect("play_new_waves_sfx", play_water_sfx)
	
func _on_music_intro_finished() -> void:
	#intro is done - start play this
	music_loop.play()

func play_water_sfx() -> void:
	player_floating_platform_adjust_height_sfx.play()
