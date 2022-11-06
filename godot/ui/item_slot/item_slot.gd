extends MarginContainer

var _main_ui
var _item_container = null
var locked = false # don't allow adding/removing items
var drop_disabled = false

signal lmb_pressed
signal rmb_pressed

func _ready():
	
	_main_ui = get_tree().current_scene.get_node("CanvasLayer/main_ui")

func _process(delta):
	
	# is the container reference set?
	if _item_container != null:
		# if the container reference has no item in it, clear the texture
		# and hide the stack size
		if _item_container.empty():
			$background/item.texture = null
			$ui_anchor/stack_size.visible = false
		# otherwise display the item thats stored in the container
		# note: the item must have a Sprite node called Sprite
		else:
			$background/item.texture = _item_container.item.get_node("Sprite").texture
			$ui_anchor/stack_size.text = str(_item_container.item.stack)
			$ui_anchor/stack_size.visible = (_item_container.item.stack > 1)

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == BUTTON_LEFT:
				emit_signal("lmb_pressed", self)
			elif event.button_index == BUTTON_RIGHT:
				emit_signal("rmb_pressed", self)
		

# set the item container reference
# leaving this as a function in case we need signals or something
func set_item_container(container):
	_item_container = container

# hide/unhide item is used during drag and drop
func hide_item():
	$background/item.visible = false
	$ui_anchor.visible = false
	
func unhide_item():
	$background/item.visible = true
	$ui_anchor.visible = true

# get drag and drop data
func get_drag_data(position):
	if _item_container == null: return null
	if _item_container.empty(): return null
	if locked: return null
	
	var item_data = {}
	item_data["source"] = _item_container
	
	# instance the dragged item ui
	var drag_preview = preload("res://ui/item_slot/drag_preview.tscn").instance()
	drag_preview.source_slot = self
	drag_preview.texture = _item_container.item.get_node("Sprite").texture
	get_tree().current_scene.get_node("CanvasLayer").add_child(drag_preview)
	
	return item_data

# able to drop dragged items on this slot?
func can_drop_data(position, data):
	if _item_container == null: return false
	elif locked: return false
	elif drop_disabled: return false
	return true

# when dropping an item on this slot
# note: assuming that the item container is valid because of can_drop_data
func drop_data(position, data):
	# remove item from source container
	var titem = data["source"].remove_item()
	# if there is already an item in this slot, lets swap it
	# if the item already there is the same type of item, stack it
	if !_item_container.empty():
		# try to stack it
		if _item_container.can_stack_with(titem):
			_item_container.add_item(titem)
			return true
		# otherwise swap
		else:
			var current_item = _item_container.remove_item()
			data["source"].add_item(current_item)
	# add the dropped item to the container
	_item_container.add_item(titem)
	return true

func get_item_name():
	if _item_container == null: return null
	if _item_container.empty(): return null
	return _item_container.item.object_name
