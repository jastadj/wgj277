extends "res://objects/game_object.gd"

export(bool) var can_pickup = true
export(bool) var is_ingredient = false
export(bool) var is_product = false
export(int) var stack = 1
export(int) var max_stack = 9999

func _ready():
	pass

func is_game_item(): return true

func get_sprite():
	return get_node("Sprite")
