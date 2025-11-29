extends Node
#Events

#emitted from player when water level is going - request since waterController will verify
signal requested_water_level_direction(is_up : bool)

#emitted from waterController when water did indeed go up
signal confirmed_new_water_level_direction(is_up : bool)

signal water_level_changed(new_water_level : int)

signal player_height_changed(new_height : float)

signal new_level_done_loading()

signal player_use()
signal player_drop()

signal load_new_level(new_level_path : String)
signal restart_current_level()

signal play_new_waves_sfx()
