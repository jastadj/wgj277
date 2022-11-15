extends Node

var item = null

# is the item container empty?
func empty():
	if item == null: return true
	else: return false
	
func remove_item():
	
	# if there's no item to remove, return nothing
	if item == null: return null
	
	# otherwise, remove the item and return it
	var titem = item
	item = null
	return titem

func can_stack_with(sitem):
	if sitem.filename == item.filename:
		var stacksize = item.stack + sitem.stack
		if item.max_stack >= stacksize:
			return true
	return false
	

func add_item(item_to_add):
	
	# if this container has no item
	if item == null:
		# if the item to add to container has a parent, remove the item as a child
		if item_to_add.get_parent():
			item_to_add.get_parent().remove_child(item_to_add)
		# set the item reference
		item = item_to_add
		return true
	# the container has an item already in it, try to stack
	else:
		# if they can stack, stack them
		if can_stack_with(item_to_add):
			item.stack += item_to_add.stack
			item_to_add.queue_free()
			return true
	# unable to add item
	return false

func increment_stack(count = 1):
	if item == null: return false
	item.stack += count
	return true
	
func decrement_stack(count = 1):
	if item == null: return false
	item.stack -= count
	if item.stack == 0:
		remove_item().queue_free()
	elif item.stack < 0:
		printerr("Error: Item stack decremented below 0!")
		return false
	return true
