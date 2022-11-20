extends PanelContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Container_mouse_entered():
	$VBoxContainer/Container.modulate = Color.red
	
func _on_Container_mouse_exited():
	$VBoxContainer/Container.modulate = Color.white
	
