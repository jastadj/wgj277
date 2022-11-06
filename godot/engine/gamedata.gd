extends Node

var message_queue = []
onready var background_container = load("res://engine/item_container.gd").new()

func _ready():
	
	
	var forbidden_cursor_image = Image.new()
	var forbidden_cursor = ImageTexture.new()
	forbidden_cursor_image.create(8,8,false,Image.FORMAT_RGBA8)
	forbidden_cursor_image.fill(Color(1,1,1,0.01))
	forbidden_cursor.create_from_image(forbidden_cursor_image)
	Input.set_custom_mouse_cursor(forbidden_cursor, Input.CURSOR_FORBIDDEN)
	
	
func add_message(msg):
	message_queue.push_back(msg)
	
func on_tree_changed():
	print("tree changed")
