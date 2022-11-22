extends Node

var _volume = 10.5

var _components

signal mixture_changed

func _init():
	clear()

func clear():
	_components = {"solids":[], "gasses":[], "liquids":[]}
	emit_signal("mixture_changed")

func get_max_volume() : return _volume

func get_volume():
	var total_vol = 0.0
	for comp_type in _components:
		for component in _components[comp_type]:
			total_vol += component["volume"]
	return total_vol

func get_volume_percent():
	return get_volume() / get_max_volume()

func _add_component(type, cname, vol, color):
	# if type is invalid, return
	if !_components.keys().has(type): return false
	# if not enough volume, return
	if (get_max_volume() - get_volume() < vol) or vol <= 0.0: return false
	# create new mixture component entry
	var new_component = {"name":cname, "volume":vol, "color":color}
	# add to component type in the mixture
	# if component name already exists, merge components
	var merged_component = false
	for component in _components[type]:
		if component["name"] == new_component["name"]:
			component["volume"] += new_component["volume"]
			merged_component = true
	# if component was not combined, add entirely new component
	if !merged_component:
		_components[type].append(new_component)
	emit_signal("mixture_changed")
	return true

func add_solid(cname, vol, color): return _add_component("solids", cname, vol, color)
func add_liquid(cname, vol, color): return _add_component("liquids", cname, vol, color)
func add_gas(cname, vol, color): return _add_component("gasses", cname, vol, color)

func remove():
	var components = _components
	clear()
	return components

func get_color():
	
	var current_volume = get_volume()
	var color = Color(0,0,0,0)
	
	for type in _components:
		for component in _components[type]:
			var cpercent = component["volume"] / current_volume
			color = color.linear_interpolate(component["color"], cpercent)
			
	return color
