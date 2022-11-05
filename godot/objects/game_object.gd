extends Node2D

class_name game_object

export(String) var object_name = "No Name"

func _ready():
	if object_name == "No Name":
		printerr("Object has no name for ", name)

#simple method check to see if this is a game object
func is_game_object(): return true
