extends Node

var plant_data = []

var message_queue = []

func _ready():
	
	load_plant_data("res://data/plants.csv")
	
	
func load_plant_data(filepath):
	var file = File.new()
	var plant_item_scene = preload("res://objects/plants/plant_item.tscn")
	
	if file.open(filepath, File.READ):
		printerr("Error opening plant data:", filepath)
		get_tree().quit(1)
	
	# get the csv header
	var header = file.get_csv_line()

	# read each line as csv
	while !file.eof_reached():
		var line = file.get_csv_line()
		if line.size() < header.size(): continue
		
		var plant = {}
		for i in header.size():
			plant[header[i]] = line[i]
		# create plant item
		plant["object"] = plant_item_scene.instance()
		plant["object"].object_name = plant["name"]
		plant["object"].index_id = plant_data.size()
		plant["object"].get_node("Sprite").texture = ResourceLoader.load(plant["sprite"])
		plant_data.push_back(plant)
	
	file.close()

func add_message(msg):
	message_queue.push_back(msg)
	
