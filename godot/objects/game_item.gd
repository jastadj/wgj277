extends "res://objects/game_object.gd"

export(bool) var can_pickup = true
export(int) var stack = 1
export(int) var max_stack = 9999

func _ready():
	pass

func is_game_item(): return true

func get_sprite():
	return get_node("Sprite")

func is_ingredient():
	
	for processor in Gamedata.recipes:
		for recipe in Gamedata.recipes[processor]:
			if recipe["inputs"].has(filename): return true
	return false
	
func is_product():
	
	for processor in Gamedata.recipes:
		for recipe in Gamedata.recipes[processor]:
			if recipe["outputs"].has(filename): return true
	return false
