extends Control

var player

var plants_ui_scene = preload("res://ui/plants/plants.tscn")

func _ready():
	
	$testbutton.connect("pressed", self, "on_testbutton_pressed")
	
	$plants.connect("pressed", self, "open_menu_scene", [plants_ui_scene])
	
	yield(get_tree().current_scene, "ready")
	player = get_tree().current_scene.get_node("objects/player")
	
	# init player inventory slots
	var item_slot = preload("res://ui/item_slot/item_slot.tscn")
	for c in $inventory.get_children():
		$inventory.remove_child(c)
		c.queue_free()
	for i in range(0, player.inventory.size()):
		var newslot = item_slot.instance()
		newslot.set_item_container(player.inventory[i])
		$inventory.add_child(newslot)
		

func _input(event):
	
	if event.is_action_pressed("ui_cancel"):
		if $open_menus.get_child_count() != 0:
			$open_menus.get_children().back().queue_free()
	
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
			
	# if any ui menus are open, disable player input
	if $open_menus.get_child_count() != 0: player.allow_input = false
	else: player.allow_input = true
		
func on_testbutton_pressed():
	Gamedata.add_message("This is a fairly long message but not too long.  Only for testing of course...")


func open_menu_scene(scene):
	
	# check if this menu is already open
	for menu in $open_menus.get_children():
		if menu.filename == scene.resource_path: return
	
	var newscene = scene.instance()
	$open_menus.add_child(newscene)

# allow drag an drop on main ui
# this will allow dropping items on the ground and also
# hide the stupid "forbidden" mouse cursor
func can_drop_data(position, data):
	return true

func drop_data(position, data):
	# remove the item from the source container
	var titem = data["source"].remove_item()
	player.drop_item(titem)
	return true
