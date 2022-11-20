extends Node

var _volume = 10.5

var _components = {"solids":[], "gasses":[], "liquids":[]}

func get_max_volume() : return _volume

func get_volume():
	var total_vol = 0.0
	for comp_type in _components:
		for component in _components[comp_type]:
			total_vol += component["volume"]
	return total_vol

func get_volume_percent():
	return get_volume() / get_max_volume()

func _add_component(type, cname, vol):
	# if type is invalid, return
	if !_components.keys().has(type): return false
	# if not enough volume, return
	if get_max_volume() - get_volume() < vol: return false
	# create new mixture component entry
	var new_component = {"name":cname, "volume":vol}
	# add to component type in the mixture
	_components[type].append(new_component)
	return true

func add_solid(cname, vol): return _add_component("solids", cname, vol)
func add_liquid(cname, vol): return _add_component("liquids", cname, vol)
func add_gas(cname, vol): return _add_component("gasses", cname, vol)
