extends HBoxContainer

var item_container

signal rmb_pressed

func _init():
	item_container = load("res://engine/item_container.gd").new()

func _ready():
	
	$item_slot._item_container = item_container
	
	# disable item slot dragging
	$item_slot.locked = true
	
	# connections
	$item_slot.connect("rmb_pressed", self, "emit_signal", ["rmb_pressed"])
	$minus_button.connect("pressed", self, "decrement_stack")
	$plus_button.connect("pressed", self, "increment_stack")

func decrement_stack():
	if item_container.item.stack > 1:
		item_container.item.stack -= 1
		
func increment_stack():
	item_container.item.stack += 1

func set_item_by_scene(item_scene):
	if item_container.empty():
		var new_item = load(item_scene).instance()
		return item_container.add_item(new_item)
	return false

func get_item_scene():
	if !item_container.empty():
		return item_container.item.filename
	return null

func get_stack_size():
	if !item_container.empty():
		return item_container.item.stack
	return null
