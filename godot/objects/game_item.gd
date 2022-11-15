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
	
	for processor in Crafting.recipes:
		for recipe in Crafting.recipes[processor]:
			if recipe["inputs"].has(filename): return true
	return false
	
func is_product():
	
	for processor in Crafting.recipes:
		for recipe in Crafting.recipes[processor]:
			if recipe["outputs"].has(filename): return true
	return false

func _save_item():
	var object = _save_object()
	object["stack"] = stack
	return object
	
func _load_item(object):
	if !_load_object(object): return false
	stack = int(object["stack"])
	return true

# redefined save for items
func save_object():
	return _save_item()
	
# redefined load for items
func load_object(object):
	return _load_item(object)
