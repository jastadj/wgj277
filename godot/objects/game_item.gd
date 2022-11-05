extends "res://objects/game_object.gd"

export(String) var item_id = "NOT_SET"
export(bool) var can_pickup = true
export(bool) var is_ingredient = false
export(bool) var is_product = false

func _ready():
	
	if item_id == "NOT_SET":
		printerr("Item ID not set for ", name)

func is_game_item(): return true

func get_sprite():
	return get_node("Sprite")
