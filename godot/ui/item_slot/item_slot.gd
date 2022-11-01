extends MarginContainer

var item_reference = null
var main_ui
var mouse_entered = false

func _ready():
	
	main_ui = get_tree().current_scene.get_node("CanvasLayer/main_ui")

func _process(delta):
	
	if item_reference == null:
		$background/item.texture = null
	else:
		$background/item.texture = item_reference.get_node("Sprite").texture

func get_item_sprite():
	return $background/item.texture

func hide_item():
	$background/item.hide()
	
func unhide_item():
	$background/item.show()

func add_item(item):
	if item_reference == null:
		item_reference = item
		$background/item.texture = item.get_sprite().texture

func remove_item():
	if item_reference == null: return null
	var titem = item_reference
	item_reference = null
	$background/item.texture = null
	return titem

func get_drag_data(position):
	
	if item_reference == null: return null
	
	var data = {}
	data["item"] = item_reference
	data["origin"] = self
	
	var drag_preview = preload("res://ui/item_slot/drag_preview.tscn").instance()
	drag_preview.texture = item_reference.get_sprite().texture
	drag_preview.source_slot = self
	get_tree().current_scene.get_node("CanvasLayer").add_child(drag_preview)
	
	return data
	
func can_drop_data(position, data):
	# stuff
	return true

func drop_data(position, data):
	# if this slot is not empty, swap
	var source_slot = data["origin"]
	if item_reference != null:
		var current_item = item_reference
		source_slot.item_reference = current_item
	# otherwise, clear the source slot's item
	else:
		source_slot.item_reference = null
	item_reference = data["item"]
