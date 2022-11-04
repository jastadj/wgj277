extends KinematicBody2D

var allow_input = true
var move_speed = 5000

var inventory_slots = 3
var _inventory_ui
var _interaction_target = null

var anim_statemachine

func _ready():
	
	yield(get_tree().current_scene, "ready")
	_inventory_ui = get_tree().current_scene.get_node("CanvasLayer/main_ui/inventory")
	
	anim_statemachine = $AnimationTree.get("parameters/StateMachine/playback")
	anim_statemachine.start("down_idle")

func _physics_process(delta):
	
	# handle movement input
	if allow_input: handle_input(delta)

func _input(event):
	
	if allow_input:
		if event.is_action_pressed("ui_cancel"): get_tree().quit()
		elif event.is_action_pressed("ui_accept"): interact(_interaction_target)
	
# just a simple method checker
func is_player(): return true

# movement input
func handle_input(delta):
	
	var move_dir = Vector2()
	
	if Input.is_action_pressed("ui_up"): move_dir.y -= 1
	if Input.is_action_pressed("ui_down"): move_dir.y += 1
	
	if Input.is_action_pressed("ui_left"): move_dir.x -= 1
	if Input.is_action_pressed("ui_right"): move_dir.x += 1
	
	if move_dir.x < 0: anim_statemachine.start("left_idle")
	elif move_dir.x > 0: anim_statemachine.start("right_idle")
	if move_dir.y < 0: anim_statemachine.start("up_idle")
	elif move_dir.y > 0: anim_statemachine.start("down_idle")
	
	move_and_slide(move_dir*move_speed*delta)

func get_interaction_areas():
	return $interaction_area.get_overlapping_areas()

func interact(obj):
	if obj == null: return
	
	# can "use" the object like a processor, computer, etc...
	if obj.has_method("has_action"):
		print("using object ", obj.object_name)
	# can pickup the object like an item
	elif obj.has_method("can_pickup"):
		print("picking up item ", obj.object_name)
		pickup_item(obj)

func pickup_item(item):
	if item == null:
		print("error picking up item, item null")
		return
	if item.has_method("can_pickup"):
		# are there free slots?
		if !has_free_inventory():
			print("unable to pickup item, no free inventory space")
			return
		# remove item from parent (if parent exists)
		var item_parent = item.get_parent()
		if item_parent: item.get_parent().remove_child(item)
		for islot in _inventory_ui.get_children():
			if islot.item_reference == null:
				islot.add_item(item)
				return

func drop_item(item):
	var random_radius = 6 # random radius to drop the item
	var objects = get_tree().current_scene.get_node("objects")
	objects.add_child(item)
	print("dropping item ", item.object_name)
	item.position = position + Vector2( (randi()%random_radius) - (random_radius/2), (randi()%random_radius) - (random_radius/2) )
		
func has_free_inventory():
	for islot in _inventory_ui.get_children():
		if islot.item_reference == null: return true
	return false
		
