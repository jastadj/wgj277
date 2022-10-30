extends PanelContainer
var text = "text missing"
var scale = 4

var _cell_size
var _text_size

func _enter_tree():
	$msg.text = text

func _ready():
	get_tree().paused = true

func _input(event):
	
	if event.is_pressed():
		if event.is_action_pressed("ui_cancel"):
			queue_free()
		elif event is InputEventMouseButton: queue_free()
		elif event is InputEventKey: queue_free()

func _exit_tree():
	get_tree().paused = false
	
