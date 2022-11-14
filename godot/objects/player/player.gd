extends KinematicBody2D

var allow_input = true
var move_speed = 5000

var inventory = []
var inventory_size = 3

var _interaction_target = null

var anim_statemachine

func _init():
	# init inventory
	_init_inventory(inventory_size)

func _ready():
		
	# get animation statemachine reference
	anim_statemachine = $AnimationTree.get("parameters/StateMachine/playback")
	anim_statemachine.start("down_idle")

func _init_inventory(isize):
	inventory = []
	var item_container = load("res://engine/item_container.gd")
	for _i in range(0, inventory_size):
		inventory.append(item_container.new())
	inventory[1].add_item(preload("res://objects/testitem/testitem.tscn").instance())

func _physics_process(delta):
	
	# handle movement input
	if allow_input: handle_input(delta)

func _input(event):
	
	# if allowing player input, e.g. when no menus are open
	if allow_input:
		if event.is_action_pressed("ui_accept"): interact(_interaction_target)
	
# just a simple method checker
func is_player(): return true

# get player save state
func save_player():
	var pdata = {"inventory":Gamedata.save_item_array(inventory)}	
	# save position
	pdata["position"] = {"x":position.x, "y":position.y}
	return pdata
	
# load player from save state
func load_player(pdata):
	
	# load inventory
	_init_inventory(pdata["inventory"].size())
	inventory = Gamedata.load_item_array(pdata["inventory"])
	# load position
	position = Vector2(pdata["position"]["x"], pdata["position"]["y"])
	return true

# movement input
func handle_input(delta):
	
	var move_dir = Vector2()
	
	if Input.is_action_pressed("ui_up"): move_dir.y -= 1
	if Input.is_action_pressed("ui_down"): move_dir.y += 1
	
	if Input.is_action_pressed("ui_left"): move_dir.x -= 1
	if Input.is_action_pressed("ui_right"): move_dir.x += 1
	
	# update animation based on player movement direction
	if move_dir.x < 0: anim_statemachine.start("left_idle")
	elif move_dir.x > 0: anim_statemachine.start("right_idle")
	if move_dir.y < 0: anim_statemachine.start("up_idle")
	elif move_dir.y > 0: anim_statemachine.start("down_idle")
	
	# move player
	move_and_slide(move_dir*move_speed*delta)

func get_interaction_areas():
	return $interaction_area.get_overlapping_areas()

func interact(obj):
	if obj == null: return
	
	# is this a static object with interaction?
	if obj.has_method("is_static_object"):
		if obj.has_action:
			obj.activate()
	# is this a game item?
	elif obj.has_method("is_game_item"):
		if obj.can_pickup: pickup_item(obj)
		
func pickup_item(obj):
	var inv_slot = null
	
	# check for any slots we can combine with
	for islot in inventory:
		if !islot.empty():
			if islot.can_stack_with(obj):
				inv_slot = islot
	# if no combinable slots found, find an empty slot
	if inv_slot == null:
		inv_slot = get_free_inventory_slot(obj)
	# if no empty slots found, fail to pickup item
	if inv_slot == null: return false
	# otherwise add the item to the slot
	inv_slot.add_item(obj)
	return true

func drop_item(obj):
	if obj == null: return false
	var drop_radius = 8
	var rand_drop_pos = Vector2(randi()%(drop_radius*2)-drop_radius, randi()%(drop_radius*2)-drop_radius)
	if obj.get_parent():
		obj.get_parent().remove_child(obj)
	obj.position = global_position + rand_drop_pos
	get_tree().current_scene.get_node("objects").add_child(obj)
	return true
	
func get_free_inventory_slot(obj = null):
	for islot in inventory:
		if islot.empty(): return islot
	return null

