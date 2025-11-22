extends Node
#global SFX util

func play_sfx(player: AudioStreamPlayer2D, from_time : float = 0) -> void:
	if not GameStats.SFX_allowed:
		return

	if from_time > 0:
		player.play(from_time)
	else:
		player.play() 
