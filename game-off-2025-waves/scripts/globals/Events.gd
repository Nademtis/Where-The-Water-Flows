extends Node
#Events

#emitted from player when water level is going
signal water_level_direction(is_up : bool)

signal water_level_changed(new_water_level : float)
