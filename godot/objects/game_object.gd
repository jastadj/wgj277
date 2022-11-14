extends Node2D

class_name game_object

export(String) var object_name = "No Name"
export(String) var object_description = "No description."

export(int) var inventory_size = 0
var inventory = []

func _ready():
	if object_name == "No Name":
		printerr("Object has no name for ", name)
		
	while inventory.size() < inventory_size:
		inventory.append(load("res://engine/item_container.gd").new())

#simple method check to see if this is a game object
func is_game_object(): return true

# base object save
func _save_object():
	var object = {}
	object["scene"] = filename
	
	if !inventory.empty():
		object["inventory"] = Gamedata.save_item_array(inventory)
	
	object["pos"] = {"x": position.x, "y": position.y}
	
	return object

# base object load
func _load_object(object):
	if object["scene"] != filename: return false
	if object.has("inventory"):
		inventory = Gamedata.load_item_array(object["inventory"])
	position = Vector2(object["pos"]["x"], object["pos"]["y"])
	return true

# redefine this function with derived object classes
func save_object():
	return _save_object()

# redefine this function with derived object classes	
func load_object(object):
	return _load_object(object)
