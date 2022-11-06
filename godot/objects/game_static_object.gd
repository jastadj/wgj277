extends "res://objects/game_object.gd"

export(bool) var has_action = false
export(PackedScene) var menu_scene = null

func is_static_object(): return true

func activate():
	if has_action:_open_menu()

func _open_menu():
	if menu_scene != null:
		get_tree().current_scene.get_node("CanvasLayer/main_ui").open_menu_scene(menu_scene, self)
