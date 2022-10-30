extends KinematicBody2D

var allow_input = true
var move_speed = 5000

func _physics_process(delta):
	
	# handle movement input
	if allow_input: handle_input(delta)

func _input(event):
	
	if allow_input:
		if event.is_action_pressed("ui_cancel"): get_tree().quit()
	
# just a simple method checker
func is_player(): return true

# movement input
func handle_input(delta):
	
	var move_dir = Vector2()
	
	if Input.is_action_pressed("ui_up"): move_dir.y -= 1
	if Input.is_action_pressed("ui_down"): move_dir.y += 1
	if Input.is_action_pressed("ui_left"): move_dir.x -= 1
	if Input.is_action_pressed("ui_right"): move_dir.x += 1
	
	move_and_slide(move_dir*move_speed*delta)

func get_interaction_areas():
	return $interaction_area.get_overlapping_areas()
