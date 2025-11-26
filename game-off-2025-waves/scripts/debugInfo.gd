extends CanvasLayer

var show_debug : bool = false

func _ready() -> void:
	if !show_debug:
		visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug"):
		show_debug = !show_debug
		visible = show_debug
