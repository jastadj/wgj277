extends "res://scenes/game/maps/map.gd"

func execute_map_script():

	var tiles = get_node("tiles")
	
	# fill background
	for y in range(-50, 50):
		for x in range(-50, 50):
			tiles.get_node("background").set_cell(x,y,16)
	
	# move player to starting position (if this is the first time they've been
	# on this map
	if !Gamedata.current_game["map_data"].has("res://scenes/game/maps/test_map/test_map.tscn"):
		var teleporters = get_node("teleporters")
		Gamedata.current_game["player"].position = teleporters.get_node("starting_position").position
