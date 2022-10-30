extends Control

var player

var plants_ui_scene = preload("res://ui/plants/plants.tscn")

func _ready():
	
	$testbutton.connect("pressed", self, "on_testbutton_pressed")
	
	$plants.connect("pressed", self, "open_menu_scene", [plants_ui_scene])
	
	yield(get_tree().current_scene, "ready")
	player = get_tree().current_scene.get_node("objects/player")

func _input(event):
	
	if event.is_action_pressed("ui_cancel"):
		if $open_menus.get_child_count() != 0:
			$open_menus.get_children().back().queue_free()

func _process(delta):
	
	var interaction_areas = player.get_interaction_areas()
	$use_item_ui.hide()
	for area in interaction_areas:
		if area.get_parent().has_method("has_action"):
			$use_item_ui.show()
			$use_item_ui.text = str("Use ",area.get_parent().object_name)
			break
			
	# if any ui menus are open, disable player input
	if $open_menus.get_child_count() != 0: player.allow_input = false
	else: player.allow_input = true
	
	
func on_testbutton_pressed():
	Gamedata.add_message("This is a fairly long message but not too long.  Only for testing of course...")

func open_menu_scene(scene):
	
	var newscene = scene.instance()
	$open_menus.add_child(newscene)
