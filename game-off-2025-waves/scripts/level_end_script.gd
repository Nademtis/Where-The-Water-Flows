extends Node2D
#level end script
@onready var stuck_in_water_amount: RichTextLabel = $StuckInWaterAmount
@onready var time_played: RichTextLabel = $TimePlayed
@onready var steps_taken: RichTextLabel = $StepsTaken

var old_step_amount : int

func _ready() -> void:
	set_play_time(GameStats.time_played)
	old_step_amount = GameStats.steps_taken
	set_stuck_in_water(GameStats.stuck_in_water_amount)


func _process(_delta: float) -> void:
	if GameStats.steps_taken > old_step_amount:
		old_step_amount = GameStats.steps_taken
		set_steps_taken(old_step_amount)

func set_play_time(time : int) -> void:
	time_played.text = str("Time Played: ", time)

func set_steps_taken(step_amount : int) -> void:
	steps_taken.text = str("Steps taken: ", step_amount)
	
func set_stuck_in_water(stuck_amount : int) -> void:
	stuck_in_water_amount.text = str("You were stuck in the water", stuck_amount, "times")
