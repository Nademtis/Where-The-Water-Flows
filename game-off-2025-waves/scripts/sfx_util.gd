extends Node
#global SFX util

func play_sfx(player: AudioStreamPlayer2D, duration : float = 0) -> void:
	if not GameStats.SFX_allowed:
		return

	if duration > 0:
		player.play(duration)
	else:
		player.play() 
