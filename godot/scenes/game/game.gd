extends Node2D

var current_map_scene

func _ready():
	
	
	
	# load the current map in
	current_map_scene = Gamedata.current_game["current_map"]
	var current_map = load(current_map_scene).instance()
	# load tiles
	if current_map.has_node("tiles"):
		var tiles = current_map.get_node("tiles")
		current_map.remove_child(tiles)
		$map.add_child(tiles)
	else:
		printerr("Error loading map ",current_map_scene, ", no tiles found!")
	# load objects
	if current_map.has_node("objects"):
		var objects = current_map.get_node("objects")
		current_map.remove_child(objects)
		$map.add_child(objects)
	else:
		printerr("Error loading map ",current_map_scene, ", no objects found!")
	# load teleporters
	if current_map.has_node("teleporters"):
		var teleporters = current_map.get_node("teleporters")
		current_map.remove_child(teleporters)
		$map.add_child(teleporters)
	else:
		printerr("Error loading map ",current_map_scene, ", no teleporters found!")
	# attach script (if present)
	var map_script = current_map.get_script()
	$map.set_script(map_script)
	# if map data exists for this map, load map data
	if Gamedata.current_game["map_data"].has(current_map_scene):
		var mapdata = Gamedata.current_game["map_data"][current_map_scene]
		$map.load_map(mapdata)
	# add player
	$map.get_node("objects").add_child(Gamedata.current_game["player"])
	# execute map script
	$map.execute_map_script()
	
	# when this map is leaving the tree, save the map data
	connect("tree_exiting", self, "_on_tree_exiting")

func _on_tree_exiting():
	# offload map data on exiting tree
	save_map()

func _process(delta):
	
	# process message queue
	if !Gamedata.message_queue.empty():
		var tmsg = Gamedata.message_queue.pop_front()
		display_message(tmsg)

func save_map():
	Gamedata.current_game["map_data"][current_map_scene] = $map.save_map()

func display_message(msg):
	var msg_box = preload("res://ui/msg_box/msg_box.tscn").instance()
	msg_box.text = msg
	$CanvasLayer/main_ui.add_child(msg_box)
