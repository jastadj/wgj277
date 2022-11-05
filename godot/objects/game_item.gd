extends "res://objects/game_object.gd"

export(bool) var can_pickup = true
export(bool) var is_ingredient = false
export(bool) var is_product = false
export(Color) var color = Color(1,1,1)

func is_gameitem(): return true

func get_sprite():
	return get_node("Sprite")
