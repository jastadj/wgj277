extends "res://objects/game_object.gd"

func is_gameitem(): return true
func can_pickup(): return true

func get_sprite():
	return get_node("Sprite")
