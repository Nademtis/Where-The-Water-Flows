extends Node
#global game stats

var water_level : float
var SFX_allowed : bool
var water_control_unlocked : bool = true
var player_allowed_to_move : bool = true


var steps_taken : int = 0
var time_played : float = 0
var stuck_in_water_amount : int = 0 


func _process(delta: float) -> void:
	time_played += delta
