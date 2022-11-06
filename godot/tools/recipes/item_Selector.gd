extends GridContainer

var item_containers = []
var items = []

signal item_selected

func _ready():
	
	for i in items:
		var container = preload("res://engine/item_container.gd").new()
		item_containers.append(container)
		var slot = preload("res://ui/item_slot/item_slot.tscn").instance()
		slot.set_item_container(container)
		container.add_item(i.duplicate())
		slot.locked = true
		slot.connect("pressed", self, "on_item_selected")
		add_child(slot)

func on_item_selected(obj):
	emit_signal("item_selected", obj._item_container.item.filename)
	queue_free()
