extends Node2D

func _ready():
	
	# load the current map in
	var current_map = load(Gamedata.current_game["current_map"]).instance()
	# load tiles
	if current_map.has_node("tiles"):
		var tiles = current_map.get_node("tiles")
		current_map.remove_child(tiles)
		$map.add_child(tiles)
	else:
		printerr("Error loading map ",Gamedata.current_game["current_map"], ", no tiles found!")
	# load objects
	if current_map.has_node("objects"):
		var objects = current_map.get_node("objects")
		current_map.remove_child(objects)
		$map.add_child(objects)
	else:
		printerr("Error loading map ",Gamedata.current_game["current_map"], ", no objects found!")
	# load teleporters
	if current_map.has_node("teleporters"):
		var teleporters = current_map.get_node("teleporters")
		current_map.remove_child(teleporters)
		$map.add_child(teleporters)
	else:
		printerr("Error loading map ",Gamedata.current_game["current_map"], ", no teleporters found!")
	# add player
	$map.get_node("objects").add_child(Gamedata.current_game["player"])
	# attach script (if present)
	var map_script = current_map.get_script()
	if map_script:
		$map.set_script(map_script)
		$map.execute_map_script()
			

func _process(delta):
	
	# process message queue
	if !Gamedata.message_queue.empty():
		var tmsg = Gamedata.message_queue.pop_front()
		display_message(tmsg)
	
func display_message(msg):
	var msg_box = preload("res://ui/msg_box/msg_box.tscn").instance()
	msg_box.text = msg
	$CanvasLayer/main_ui.add_child(msg_box)
