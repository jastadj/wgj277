extends Control

var header

func _ready():
	
	header = $PanelContainer/GridContainer/header
	var name = header.get_node("name")
	var centrifuge = header.get_node("centrifuge")
	var incinerate = header.get_node("incinerate")
	var juice = header.get_node("juice")
	var grind = header.get_node("grind")
	
