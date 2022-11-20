extends MarginContainer

var _main_ui
var _item_container
var drop_disabled = false

signal lmb_pressed
signal rmb_pressed

func _ready():
	
	_main_ui = get_tree().current_scene.get_node("CanvasLayer/main_ui")
	
	set_item_container(_item_container)

func set_item_container(container):
	if !container: return false
	if !_item_container: _item_container = container
	if !_item_container.is_connected("item_changed", self, "update_slot"):
		_item_container.connect("item_changed", self, "update_slot")
	update_slot()
	return true

func update_slot():
	
	if !_item_container:
		$background/item.texture = null
		$ui_anchor/stack_size.visible = false
		return
	
	# if the container reference has no item in it, clear the texture
	# and hide the stack size
	if _item_container.empty():
		$background/item.texture = null
		$ui_anchor/stack_size.visible = false
	# otherwise display the item thats stored in the container
	# note: the item must have a Sprite node called Sprite
	else:
		$background/item.texture = _item_container.item.get_node("Sprite").texture
		var stack_size = _item_container.item.stack
		if is_inside_tree():
			var drag_data = get_viewport().gui_get_drag_data()
			# if drag data is valid
			if drag_data != null:
				# and the source container equals this item container
				if drag_data["source"] == _item_container:
					# update the stack size
					stack_size = drag_data["leave_behind"]
					# if the stack size is greater than 0, show item
					if stack_size > 0: unhide_item()
		$ui_anchor/stack_size.text = str(stack_size)
		$ui_anchor/stack_size.visible = (stack_size > 1)	



func _gui_input(event):
	if !_item_container: return
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == BUTTON_LEFT:
				emit_signal("lmb_pressed", self)
			elif event.button_index == BUTTON_RIGHT:
				if get_viewport().gui_is_dragging():
					#print("RMB clicked on item slot while dragging")
					var drag_data = get_viewport().gui_get_drag_data()
					var dragging_from_container = drag_data["source"]
					var dragging_from_slot_ui = drag_data["source_ui"]
					var dragging_item = dragging_from_container.item
					var dragging_item_stack = dragging_item.stack
					# the dragged stack must be greater than one
					if dragging_item_stack > 1:
						# when destination is not the same as source container
						if (dragging_from_container != _item_container):
							# if the container is empty, create new item
							# and attempt to add to slot, if successful, decrement dragged stack
							if _item_container.empty():
								var new_item = load(dragging_item.filename).instance()
								if _item_container.add_item(new_item):
									dragging_from_container.decrement_stack()
							# if the container contains the same item being dragged, increment it
							# and decrement the stack
							elif _item_container.item.filename == dragging_from_container.item.filename:
								if _item_container.increment_stack():
									if !dragging_from_container.decrement_stack():
										printerr("Error dropping an item from the dragged stack!")
						# when right-click dropping on source slot
						else:
							_leave_behind(1)
				# if not dragging
				else:
					# and there are items in the container and container isn't locked
					if !_item_container.empty() and !_item_container.locked:
						print("splitting the stack")
						# drag the items with the RMB (split the stack)
						var drag_data = _get_drag_item_data()
						drag_data["right_drag"] = true
						if drag_data["source"].item.stack > 1:
							var split_size = int(drag_data["source"].item.stack/2)
							drag_data["source"].item.stack = drag_data["source"].item.stack - split_size
							drag_data["leave_behind"] = split_size
							print(drag_data)
							force_drag(drag_data, _drag_item_preview() )
							update_slot()
							
				
				emit_signal("rmb_pressed", self)
		

func lock():
	if _item_container: _item_container.lock()

func unlock():
	if _item_container: _item_container.unlock()

# hide/unhide item is used during drag and drop
func hide_item():
	$background/item.visible = false
	$ui_anchor.visible = false
	
func unhide_item():
	$background/item.visible = true
	$ui_anchor.visible = true

# get drag and drop data
# note: main game script also checks for drag begin notification
func get_drag_data(position):
	
	var item_data = _get_drag_item_data()
	if item_data == null: return null
	
	get_tree().current_scene.get_node("CanvasLayer").add_child(_drag_item_preview())
	
	return item_data

func _get_drag_item_data():
	if _item_container == null: return null
	if _item_container.empty(): return null
	if _item_container.locked: return null
	
	var item_data = {}
	item_data["source"] = _item_container
	item_data["source_ui"] = self
	item_data["leave_behind"] = 0
	return item_data

func _drag_item_preview():
	# instance the dragged item ui
	var drag_preview = preload("res://ui/item_slot/drag_preview.tscn").instance()
	drag_preview.source_slot = self
	drag_preview.get_node("Sprite").texture = _item_container.item.get_node("Sprite").texture
	return drag_preview
	

# able to drop dragged items on this slot?
func can_drop_data(position, data):
	if _item_container == null: return false
	elif _item_container.locked: return false
	elif drop_disabled: return false
	# if leaving part of the stack behind, this slot must be empty or of same type
	if data["leave_behind"] != 0:
		if !_item_container.empty():
			if !_item_container.can_stack_with(data["source"].item):
				return false
	return true

# when dropping an item on this slot
# note: assuming that the item container is valid because of can_drop_data
# note: the main game script also checks notifications for drag end
func drop_data(position, data):
	# remove item from source container if not leaving an stack behind
	var titem
	var leaving_behind = data["leave_behind"]
	# if not leaving any of the stack behind in the original slot
	if leaving_behind == 0:
		titem = data["source"].remove_item()
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
	else:
		# note - the can_drop_data handles the logic on whether this
		# slot can be dropped on, no need to duplicate logic
		print("dropping a drag where items are left behind")
		# when dropping on the source container, combine the leave behind
		# and the current stack
		if data["source"] == _item_container:
			_item_container.increment_stack(data["leave_behind"])
		# otherwise we are dropping this item on a different slot
		# this slot is either empty or contains the same item
		# we will need to create another item and adjust stacks
		else:
			titem = data["source"].item
			var newitem = titem.duplicate()
			# new items stack amount is the amount held by the drag
			newitem.stack = titem.stack
			# original items stack amount is amount being left behind
			titem.stack = data["leave_behind"]
			# add new item to this container (combine or add new)
			_item_container.add_item(newitem)
			
		update_slot()
		data["source_ui"].update_slot()
	return true

func is_dragging():
	if !get_viewport().gui_is_dragging(): return false
	var drag_data = get_viewport().gui_get_drag_data()
	if drag_data["source"] != _item_container: return false
	return true

# leave a portion of the stack size behind during drag
func _leave_behind(stack):
	
	if !is_dragging(): return false
	var drag_data = get_viewport().gui_get_drag_data()
	var item = drag_data["source"].item
	
	# item stack must be greater than 1 (should never be 0)
	if item.stack <= 1: return false
	
	# if leaving behind more items than are in the stack-1, adjust
	# the amount leaving behind
	if stack > item.stack - 1:
		stack = item.stack - 1
	
	# subtract the leave behind amount from the item stack
	item.stack -= stack
	
	# sum the leave behind amount
	drag_data["leave_behind"] += stack
		
	# update the slot to display the stack behind left behind
	update_slot()			
	return true

func get_item_name():
	if _item_container == null: return null
	if _item_container.empty(): return null
	return _item_container.item.object_name

