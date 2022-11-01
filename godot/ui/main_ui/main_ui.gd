extends Control

var player

var plants_ui_scene = preload("res://ui/plants/plants.tscn")

var _dragged_item = null
var _dragged_item_previous_slot = null
var _dragged_item_mouse_offset = Vector2()


func _ready():
	
	$testbutton.connect("pressed", self, "on_testbutton_pressed")
	
	$plants.connect("pressed", self, "open_menu_scene", [plants_ui_scene])
	
	yield(get_tree().current_scene, "ready")
	player = get_tree().current_scene.get_node("objects/player")

	update_inventory_slots()

func _input(event):
	
	if event.is_action_pressed("ui_cancel"):
		if $open_menus.get_child_count() != 0:
			$open_menus.get_children().back().queue_free()

func _unhandled_input(event):
	
	# dropped a dragged item slot?
	if event is InputEventMouseButton:
		pass
	
func _process(delta):
	
	var interaction_areas = player.get_interaction_areas()
	player._interaction_target = null
	$interaction_ui.hide()
	for area in interaction_areas:
		if area.get_parent().has_method("has_action"):
			$interaction_ui.show()
			$interaction_ui.text = str("Use ",area.get_parent().object_name)
			player._interaction_target = area.get_parent()
			break
		elif area.get_parent().has_method("can_pickup"):
			$interaction_ui.show()
			$interaction_ui.text = str("Pickup ", area.get_parent().object_name)
			player._interaction_target = area.get_parent()
			break

	# if dragging an item
	if _dragged_item != null:
		$dragged_item.texture = _dragged_item.get_sprite().texture
		$dragged_item.show()
		$dragged_item.rect_position = get_global_mouse_position() - _dragged_item_mouse_offset
	else:
		$dragged_item.hide()
			
	# if any ui menus are open, disable player input
	if $open_menus.get_child_count() != 0: player.allow_input = false
	else: player.allow_input = true
	
func update_inventory_slots():
	var slot_scene = preload("res://ui/item_slot/item_slot.tscn")
	for child in $inventory.get_children():
		$inventory.remove_child(child)
		child.queue_free()
	for i in range(0, player.inventory_slots):
		var newslot = slot_scene.instance()
		newslot.name = str("inventory_",i)
		$inventory.add_child(newslot)
		
func on_testbutton_pressed():
	Gamedata.add_message("This is a fairly long message but not too long.  Only for testing of course...")


func open_menu_scene(scene):
	
	# check if this menu is already open
	for menu in $open_menus.get_children():
		if menu.filename == scene.resource_path: return
	
	var newscene = scene.instance()
	$open_menus.add_child(newscene)
	
# allow dropping items on the main ui (drops on the ground)
func can_drop_data(position, data):
	return true
	
func drop_data(position, data):
	# drop item on the ground
	# if this slot is not empty, swap
	var source_slot = data["origin"]
	var titem = data["item"]
	source_slot.item_reference = null
	player.drop_item(titem)
