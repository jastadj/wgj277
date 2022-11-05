extends "res://objects/game_object.gd"

func _ready():
	object_name = "Juicer"

# simple method checker
# can be used by the main ui to check all the overlapping areas that the player
# is in and if it has this method, display the "use item" ui
func has_action(): return true

