extends "res://objects/game_item.gd"

export(float) var volume = 10.5

var mixture = load("res://engine/mixture.gd").new()
var fill_rect = null

func is_mixture_container(): return true

func _init():
	mixture._volume = volume

func _ready():
	fill_rect = $Sprite/fill.region_rect
	_update_fill_rect()

func _update_fill_rect():
	if !fill_rect or !mixture: return false
	var fill = $Sprite/fill
	var percent = mixture.get_volume_percent()
	fill.region_rect.size = Vector2(fill_rect.size.x, fill_rect.size.y * percent)
	fill.region_rect.position = Vector2(fill_rect.position.x, fill_rect.position.y + (fill_rect.size.y - (fill_rect.size.y*percent)))
	return true	

func get_sprite():
	_update_fill_rect()
	return get_node("Sprite").duplicate()
