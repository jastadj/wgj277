extends Control

var header

func _ready():
	
	header = $PanelContainer/GridContainer/header
	var name = header.get_node("name")
	var boil = header.get_node("boil")
	var incinerate = header.get_node("incinerate")
	var juice = header.get_node("juice")
	var grind = header.get_node("grind")
	
	var row_counter = 0
	
	for plant in Gamedata.plant_data:
		
		# name
		var new_name = name.get_node("name").duplicate()
		new_name.name = str("row",row_counter)
		new_name.text = plant["name"]
		name.add_child(new_name)
		
		# boil
		var new_boil = boil.get_node("boil").duplicate()
		new_boil.name = str("row",row_counter)
		new_boil.text = plant["boil"]
		boil.add_child(new_boil)
		
		# incinerate
		var new_incinerate = incinerate.get_node("incinerate").duplicate()
		new_incinerate.name = str("row",row_counter)
		new_incinerate.text = plant["incinerate"]
		incinerate.add_child(new_incinerate)
		
		# juice
		var new_juice = juice.get_node("juice").duplicate()
		new_juice.name = str("row", row_counter)
		new_juice.text = plant["juice"]
		juice.add_child(new_juice)
		
		# grind
		var new_grind = grind.get_node("grind").duplicate()
		new_grind.name = str("row", row_counter)
		new_grind.text = plant["grind"]
		grind.add_child(new_grind)
