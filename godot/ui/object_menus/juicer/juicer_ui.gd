extends PanelContainer

var object_owner = null

onready var input_slot = $contents/HBoxContainer/input
onready var output_slot = $contents/HBoxContainer/output

func _ready():
	
	# disable dropping items on the output slot
	output_slot.drop_disabled = true
	
	# connect the item slots to the juicer machine
	if object_owner:
		input_slot.set_item_container(object_owner.inventory[0])
		output_slot.set_item_container(object_owner.inventory[1])
	
	$contents/button_process.connect("pressed", self, "_on_button_process_pressed")
	
func _on_button_process_pressed():
	Gamedata.process_recipe(object_owner.filename, [input_slot._item_container],[output_slot._item_container])
