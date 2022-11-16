extends GridContainer

var item_containers = []
var items

signal item_selected

func _ready():
	
	if items == null:
		printerr("Error opening item selector, items = null")
		queue_free()
		return
	
	for i in items:
		var container = preload("res://engine/item_container.gd").new()
		item_containers.append(container)
		var slot = preload("res://ui/item_slot/item_slot.tscn").instance()
		slot._item_container = container
		container.add_item(i.duplicate())
		container.locked = true
		slot.connect("lmb_pressed", self, "on_item_selected")
		add_child(slot)

func on_item_selected(obj):
	emit_signal("item_selected", obj._item_container.item.filename)
	queue_free()
