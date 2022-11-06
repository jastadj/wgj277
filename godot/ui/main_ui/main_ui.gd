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
		# if menus are opened, close the last menu opened
		if menus_opened():
			$open_menus.get_children().back().queue_free()
	
func _process(delta):
	
	# get all the areas that the player is touching
	var interaction_areas = player.get_interaction_areas()
	
	# clear the players current interaction target
	player._interaction_target = null
	$interaction_ui.hide()
	
	# check each area the player is touching, first interactable object found
	# will be set as the players current interaction target
	for area in interaction_areas:
		var obj = area.get_parent()
		
		# is this area part of a game object?
		if obj.has_method("is_game_object"):
			# is this game object static?
			if obj.has_method("is_static_object"):
				# does this static object have an action?
				if obj.has_action:
					$interaction_ui.show()
					$interaction_ui.text = str("Use ",obj.object_name)
					player._interaction_target = obj
					break
			# is this game object an item?
			elif obj.has_method("is_game_item"):
				# can it be picked up?
				if obj.can_pickup:
					$interaction_ui.show()
					$interaction_ui.text = str("Pickup ", obj.object_name)
					player._interaction_target = obj
					break
			
	# if any ui menus are open, disable player input
	# also, hide the interaction ui text
	if menus_opened():
		player.allow_input = false
		$interaction_ui.hide()
	else: player.allow_input = true
		
func on_testbutton_pressed():
	Gamedata.add_message("This is a fairly long message but not too long.  Only for testing of course...")

func menus_opened():
	if $open_menus.get_child_count() != 0: return true
	return false

func open_menu_scene(scene, object_owner = null):
	
	# check if this menu is already open
	for menu in $open_menus.get_children():
		if menu.filename == scene.resource_path: return
	
	# instance the scene and add it to the main ui
	var newscene = scene.instance()
	# if an owner was provided, set the owner
	if object_owner:
		newscene.object_owner = object_owner
	$open_menus.add_child(newscene)

# allow drag an drop on main ui
# this will allow dropping items on the ground and also
# hide the stupid "forbidden" mouse cursor
func can_drop_data(position, data):
	return false
	return true

func drop_data(position, data):
	# remove the item from the source container
	var titem = data["source"].remove_item()
	player.drop_item(titem)
	return true
