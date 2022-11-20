extends PanelContainer

func _ready():
	get_tree().paused = true
	
func _exit_tree():
	get_tree().paused = false

func _input(event):
	
	if event.is_action_pressed("ui_cancel"):
		queue_free()

func _on_save_button_pressed():
	Gamedata.save_game()
	queue_free()


func _on_quit_game_button_pressed():
	get_tree().quit()


func _on_quit_main_menu_button_pressed():
	get_tree().change_scene("res://scenes/main_menu/main_menu.tscn")


func _on_settings_button_pressed():
	pass # Replace with function body.
