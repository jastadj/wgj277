extends Sprite	

var source_slot = null

func _ready():
	
	if source_slot:
		source_slot.hide_item()
		
func _exit_tree():
	if source_slot:
		source_slot.unhide_item()

func _process(delta):
	
	position = get_global_mouse_position()

func _input(event):
	
	if event is InputEventMouseButton:
		if event.is_pressed() == false and event.button_index == BUTTON_LEFT:
			queue_free()
