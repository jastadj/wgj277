extends MarginContainer

var _main_ui
var _item_container = null

func _ready():
	
	_main_ui = get_tree().current_scene.get_node("CanvasLayer/main_ui")

func _process(delta):
	
	# is the container reference set?
	if _item_container != null:
		# if the container reference has no item in it, clear the texture
		if _item_container.empty(): $background/item.texture = null
		# otherwise display the item thats stored in the container
		# note: the item must have a Sprite node called Sprite
		else:
			$background/item.texture = _item_container.item.get_node("Sprite").texture

# set the item container reference
# leaving this as a function in case we need signals or something
func set_item_container(container):
	_item_container = container

# hide/unhide item is used during drag and drop
func hide_item():
	$background/item.visible = false	
func unhide_item():
	$background/item.visible = true

# get drag and drop data
func get_drag_data(position):
	if _item_container == null: return null
	if _item_container.empty(): return null
	
	var item_data = {}
	item_data["source"] = _item_container
	
	# instance the dragged item ui
	var drag_preview = preload("res://ui/item_slot/drag_preview.tscn").instance()
	drag_preview.source_slot = self
	drag_preview.texture = _item_container.item.get_node("Sprite").texture
	get_tree().current_scene.get_node("CanvasLayer").add_child(drag_preview)
	
	return item_data

# able to drop dragged items on this slot?  yes, only if container is valid
func can_drop_data(position, data):
	if _item_container == null: return false
	return true

# when dropping an item on this slot
# note: assuming that the item container is valid because of can_drop_data
func drop_data(position, data):
	# remove item from source container
	var titem = data["source"].remove_item()
	# if there is already an item in this slot, lets swap it
	if !_item_container.empty():
		var current_item = _item_container.remove_item()
		data["source"].add_item(current_item)
	# add the dropped item to the container
	_item_container.add_item(titem)
	return true
