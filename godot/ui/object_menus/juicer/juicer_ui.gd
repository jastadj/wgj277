extends PanelContainer

var object_owner = null

onready var input_slot = $contents/HBoxContainer/input
onready var output_slot = $contents/HBoxContainer/output

func _ready():
	
	# connect the item slots to the juicer machine
	if object_owner:
		input_slot.set_item_container(object_owner.input_slot)
		output_slot.set_item_container(object_owner.output_slot)
	
	$contents/button_process.connect("pressed", self, "_on_button_process_pressed")
	
func _on_button_process_pressed():
	pass
