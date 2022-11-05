extends Node2D

func _process(delta):
	
	# process message queue
	if !Gamedata.message_queue.empty():
		var tmsg = Gamedata.message_queue.pop_front()
		display_message(tmsg)
	
	# fill background
	for y in range(-50, 50):
		for x in range(-50, 50):
			$background.set_cell(x,y,16)
	
func display_message(msg):
	var msg_box = preload("res://ui/msg_box/msg_box.tscn").instance()
	msg_box.text = msg
	$CanvasLayer/main_ui.add_child(msg_box)
