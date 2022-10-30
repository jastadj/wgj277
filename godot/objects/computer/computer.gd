extends "res://objects/game_object.gd"

func _ready():
	
	object_name = "Computer"
	
	# run animations
	$Sprite/AnimationPlayer.play("running")
	$screen/AnimationPlayer.play("running")

func has_action(): return true
