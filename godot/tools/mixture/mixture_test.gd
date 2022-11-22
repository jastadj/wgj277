extends Node2D

onready var item_slot = $CanvasLayer/main_ui/item_slot
onready var item_container = load("res://engine/item_container.gd").new()
var mixture
onready var percent_label = $CanvasLayer/main_ui/PanelContainer/VBoxContainer/HBoxContainer/percent
onready var max_vol_label = $CanvasLayer/main_ui/PanelContainer/VBoxContainer/HBoxContainer2/max_vol
onready var cur_vol_label = $CanvasLayer/main_ui/PanelContainer/VBoxContainer/HBoxContainer3/cur_vol

onready var liquid_list = $CanvasLayer/main_ui/PanelContainer/VBoxContainer/liquids
onready var solid_list = $CanvasLayer/main_ui/PanelContainer/VBoxContainer/solids
onready var gas_list = $CanvasLayer/main_ui/PanelContainer/VBoxContainer/gasses

onready var add_slider = $CanvasLayer/main_ui/VBoxContainer/HBoxContainer2/addslider

var type_lists = []

func _ready():
	
	item_slot.update_slot()
	
	var beaker = preload("res://objects/beaker/beaker.tscn").instance()
	item_slot.set_item_container(item_container)
	item_slot.lock()
	item_container.add_item(beaker)
	
	mixture = beaker.mixture
	mixture.connect("mixture_changed", self, "_on_mixture_changed")
	
	type_lists.append(liquid_list)
	type_lists.append(solid_list)
	type_lists.append(gas_list)
	
	# initial update
	_on_mixture_changed()

func _process(delta):
	$CanvasLayer/main_ui/VBoxContainer/adding_volume_label.text = str("Adding Volume:", add_slider.value)

func _on_mixture_changed():

	percent_label.text = str(mixture.get_volume_percent()*100.0)
	max_vol_label.text = str(mixture.get_max_volume())
	cur_vol_label.text = str(mixture.get_volume())
	
	# clear list
	for tlist in type_lists:
		for child in tlist.get_children():
			child.queue_free()
	
	# build mixture list
	for ctype in mixture._components:
		for component in mixture._components[ctype]:
			_add_component_list_entry(ctype, component)
			
func _add_component_list_entry(type, component):
	
	var target_list = null
	if type == "solids": target_list = solid_list
	elif type == "liquids": target_list = liquid_list
	elif type == "gasses": target_list = gas_list
	
	if target_list == null:
		printerr("Unable to add component list entry, type ", type," unknown.")
		return false
	
	var new_entry = HBoxContainer.new()
	var name_label = Label.new()
	var vol_label = Label.new()
	var colorrect = ColorRect.new()
	
	name_label.text = str(component["name"])
	vol_label.text = str("Volume:", component["volume"])
	colorrect.rect_min_size = Vector2(16,16)
	colorrect.color = component["color"]
	
	new_entry.add_child(colorrect)
	new_entry.add_child(name_label)
	new_entry.add_child(vol_label)
	
	
	target_list.add_child(new_entry)
	return true
	


func _on_add_liquid_pressed(): edit_new_component("liquid")
func _on_add_solid_pressed(): edit_new_component("solid")
func _on_add_gas_pressed(): edit_new_component("gas")

func edit_new_component(type):
	
	$CanvasLayer/main_ui/Popup/PanelContainer/VBoxContainer/HBoxContainer/type.text = type
	
	$CanvasLayer/main_ui/Popup/PanelContainer/VBoxContainer/HBoxContainer2/nameinput.text = ""
	$CanvasLayer/main_ui/Popup/PanelContainer/VBoxContainer/HBoxContainer4/volumeinput.text = "0.0"
	$CanvasLayer/main_ui/Popup/PanelContainer/VBoxContainer/ColorPicker.color = Color.white
	$CanvasLayer/main_ui/Popup.popup()


func _on_add_button_pressed():
	var ctype = $CanvasLayer/main_ui/Popup/PanelContainer/VBoxContainer/HBoxContainer/type.text
	var cname = $CanvasLayer/main_ui/Popup/PanelContainer/VBoxContainer/HBoxContainer2/nameinput.text
	var cvol = $CanvasLayer/main_ui/Popup/PanelContainer/VBoxContainer/HBoxContainer4/volumeinput.text
	var ccolor = $CanvasLayer/main_ui/Popup/PanelContainer/VBoxContainer/ColorPicker.color
	mixture.call(str("add_",ctype), cname, float(cvol), ccolor )

func _on_cancel_button_pressed():
	$CanvasLayer/main_ui/Popup.hide()

func _on_remove_pressed():
	print("removed mixture:", mixture.remove())


func _on_addblood_pressed(): mixture.add_liquid("blood", add_slider.value, Color.red)
func _on_addblueberryjuice_pressed(): mixture.add_liquid("blueberry juice", add_slider.value, Color.blue)
func _on_addantifreeze_pressed():
	var color = Color.lime
	color.a = 0.5
	mixture.add_liquid("antifreeze", add_slider.value, color)
func _on_addcarbon_pressed(): mixture.add_solid("carbon", add_slider.value, Color.slategray)
func _on_addcocaine_pressed(): mixture.add_solid("cocaine", add_slider.value, Color.white)
func _on_addcaffeine_pressed(): mixture.add_solid("caffeine", add_slider.value, Color.white)
func _on_addhydrogen_pressed(): mixture.add_gas("hydrogen", add_slider.value, Color.aquamarine)
func _on_addoxygen_pressed(): mixture.add_gas("oxygen", add_slider.value, Color.aqua)
func _on_addco2_pressed(): mixture.add_gas("co2", add_slider.value, Color.burlywood)

