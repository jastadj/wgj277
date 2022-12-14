extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_new_game_pressed():
	Gamedata.new_game()
	get_tree().change_scene("res://scenes/game/game.tscn")


func _on_quit_pressed():
	get_tree().quit()


func _on_continue_game_pressed():
	if Gamedata.load_game():
		get_tree().change_scene("res://scenes/game/game.tscn")


func _on_recipe_editor_pressed():
	get_tree().change_scene("res://tools/recipes/recipes.tscn")
