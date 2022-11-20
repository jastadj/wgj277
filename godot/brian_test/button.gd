extends MarginContainer

export(String) var mytext = "test button"

func _ready():
	$HBoxContainer/Label.text = mytext
