extends Node

var message_queue = []

var current_game = {}

var settings_file = "user://settings.json"
var save_dir = "user://saves/slot0"

onready var background_container = load("res://engine/item_container.gd").new()
var settings = {"tooltip_delay":500}

func _ready():
	
	# load settings
	# if unable to load settings, save the current default settings to file
	if !load_settings(): save_settings()
	
	# init forbidden mouse cursor
	# this is to hide the mouse cursor when drag and drop is forbidden
	var forbidden_cursor_image = Image.new()
	var forbidden_cursor = ImageTexture.new()
	forbidden_cursor_image.create(8,8,false,Image.FORMAT_RGBA8)
	forbidden_cursor_image.fill(Color(1,1,1,0.01))
	forbidden_cursor.create_from_image(forbidden_cursor_image)
	Input.set_custom_mouse_cursor(forbidden_cursor, Input.CURSOR_FORBIDDEN)

func save_settings(file_name = settings_file):
	print("Saving settings to file:", file_name)
	var file = File.new()
	if !file.open(file_name, File.WRITE) == OK:
		printerr("Error saving settings to file:", file_name)
		return false
	file.store_string(JSON.print(settings))
	file.close()
	return true
	
func load_settings(file_name = settings_file):
	print("Loading settings from file:", file_name)
	var file = File.new()
	if !file.open(file_name, File.READ) == OK:
		printerr("Error loading settings from file:", file_name)
		return false
	var filestr = file.get_line()
	if filestr.empty():
		printerr("Settings file is invalid!")
		return false
	var loaded_settings = JSON.parse(filestr).result
	settings.merge(loaded_settings, true)
	file.close()
	return true

func new_game():
	current_game = {}
	current_game["player"] = preload("res://objects/player/player.tscn").instance()
	current_game["current_map"] = "res://scenes/game/maps/test_map/test_map.tscn"
	current_game["map_data"] = {}


func save_game(slot_dir = save_dir):
	
	var dir = Directory.new()
	
	print("Saving game...")
	
	# if save directory exists, delete files from folder
	if dir.dir_exists(slot_dir):
		var file_tools = load("res://tools/file_tools.gd").new()
		if !file_tools.delete_files_in_dir(slot_dir, false):
			printerr("Error deleting files from save dir ", slot_dir)
			return false
	# otherwise, create directory folder
	else:
		if dir.make_dir_recursive(save_dir) != OK:
			printerr("Error creating save directory ", slot_dir)
			return false
		else:
			print("Created save directory ", slot_dir)
			
	# save serialized game data to save dir
	var file = File.new()
	file.open(str(slot_dir, "/save.json"), File.WRITE)
	var save_data = {}
	save_data["player"] = Gamedata.current_game["player"].save_player()
	save_data["current_map"] = Gamedata.current_game["current_map"]
	# save map data
	# if the game scene is currently open, save it to map data
	if get_tree().current_scene.filename == "res://scenes/game/game.tscn":
		get_tree().current_scene.save_map()
	save_data["map_data"] = Gamedata.current_game["map_data"]
	file.store_line(to_json(save_data))
	file.close()
	
	print("Game saved.")
	return true
	
func load_game(slot_dir = save_dir):
	var dir = Directory.new()
	var file = File.new()
	var savefile = str(slot_dir, "/save.json")
	
	print("Loading game ", slot_dir)
	
	# create new game
	new_game()
	
	# check save file and save directory
	if !dir.dir_exists(slot_dir):
		printerr("Error loading game, save directory does not exist:", slot_dir)
		return false
	if file.open(savefile,File.READ) != OK:
		printerr("Error loading ", savefile)
		return false
	var saveline = file.get_line()
	var savejson = JSON.parse(saveline).result
	current_game["player"].load_player(savejson["player"])
	current_game["current_map"] = savejson["current_map"]
	current_game["map_data"] = savejson["map_data"]
	
	print("Game loaded.")
	return true

# add a message to the queue for processing (displays message box)
func add_message(msg):
	message_queue.push_back(msg)

# serialize an array of items
func save_item_array(iarray):
	var iasave = []
	for i in range(0,iarray.size()):
		if iarray[i].empty():
			iasave.append(null)
		else:
			iasave.append(iarray[i].item.save_object())
	return iasave

# deserialize an array of items
func load_item_array(iasave):
	var iarray = []
	print(iasave)
	for i in range(0, iasave.size()):
		var newslot = preload("res://engine/item_container.gd").new()
		iarray.append(newslot)
		if iasave[i] == null: continue
		var newitem = load(iasave[i]["scene"]).instance()
		if newitem.load_object(iasave[i]):
			newslot.item = newitem
		else:
			printerr("Error loading item array, item load failed:", iasave[i]["scene"])
	return iarray
