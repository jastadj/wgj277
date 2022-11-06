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

func add_item(item_to_add):
	
	# if this container has no item
	if item == null:
		# if the item to add to container has a parent, remove the item as a child
		if item_to_add.get_parent():
			item_to_add.get_parent().remove_child(item_to_add)
		# set the item reference
		item = item_to_add
		return true
	# the container already has an item in it
	else:
		return false
	 
