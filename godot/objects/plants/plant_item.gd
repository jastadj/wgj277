extends "res://objects/game_item.gd"

export(int) var index_id = 0

func _ready():
	
	# get plant data reference
	var _plant_data = Gamedata.plant_data[index_id]
	
	# setup plant
	object_name = _plant_data["name"]
	$Sprite.texture = ResourceLoader.load(_plant_data["sprite"])
	
