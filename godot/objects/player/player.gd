extends KinematicBody2D

var allow_input = true
var move_speed = 5000

func _physics_process(delta):
	
	# handle movement input
	if allow_input: handle_input(delta)

# movement input
func handle_input(delta):
	
	var move_dir = Vector2()
	
	if Input.is_action_pressed("ui_up"): move_dir.y -= 1
	if Input.is_action_pressed("ui_down"): move_dir.y += 1
	if Input.is_action_pressed("ui_left"): move_dir.x -= 1
	if Input.is_action_pressed("ui_right"): move_dir.x += 1
	
	
	
	move_and_slide(move_dir*move_speed*delta)
