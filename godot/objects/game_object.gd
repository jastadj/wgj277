extends Node2D

class_name game_object

export(String) var object_name = "No Name"
export(String) var object_description = "No description."

func _ready():
	if object_name == "No Name":
		printerr("Object has no name for ", name)

#simple method check to see if this is a game object
func is_game_object(): return true
