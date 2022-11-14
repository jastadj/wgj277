class_name map
extends Node2D

func execute_map_script():
	pass

func save_map():
	var mapdata = {}
	
	mapdata["objects"] = []
	for object in $objects.get_children():
		if object.has_method("is_player"): continue
		mapdata["objects"].append(object.save_object())
	
	return mapdata
		
func load_map(mapdata):
	
	if mapdata.has("objects"):
		
		# clear existing objects
		for object in $objects.get_children():
			$objects.remove_child(object)
			object.queue_free()
		
		# create objects from mapdata object list
		for object in mapdata["objects"]:
			var newobject = load(object["scene"]).instance()
			newobject.load_object(object)
			$objects.add_child(newobject)
