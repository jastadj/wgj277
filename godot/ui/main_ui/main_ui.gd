extends Control

func _ready():
	
	$testbutton.connect("pressed", self, "on_testbutton_pressed")
	
func on_testbutton_pressed():
	Gamedata.add_message("This is a fairly long message but not too long.  Only for testing of course...")
