extends Node

@onready var music_intro: AudioStreamPlayer = $musicIntro
@onready var music_loop: AudioStreamPlayer = $musicLoop

func _ready() -> void:
	music_intro.play(0)
	
	
func _on_music_intro_finished() -> void:
	#intro is done - start play this
	music_loop.play()
