extends Node2D
class_name InteractIndicator

@onready var audio_stream_player_2d_entered: AudioStreamPlayer2D = $AudioStreamPlayer2DEntered
@onready var audio_stream_player_2d_exited: AudioStreamPlayer2D = $AudioStreamPlayer2DExited

func _ready() -> void:
	visible = false

func show_indicator()-> void:
	if not is_inside_tree():
		return
	#SFX.play_sfx(audio_stream_player_2d_entered)
	audio_stream_player_2d_entered.play()
	visible = true
	
func hide_indicator() -> void:
	if not is_inside_tree():
		return
	#SFX.play_sfx(audio_stream_player_2d_exited)
	audio_stream_player_2d_exited.play()
	visible = false
	
