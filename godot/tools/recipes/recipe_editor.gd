extends PanelContainer

onready var items = get_tree().current_scene.items
onready var processors = get_tree().current_scene.processors
var _item_select_menu = null
var _item_select_menu_scene = preload("res://tools/recipes/item_Selector.tscn")
onready var _menus = get_tree().current_scene.menus
var _editing_recipe = null # used to indicate if editing an existing recipe, null for new recipe

var inputs = []
var outputs = []

signal recipe_created
signal recipe_edited

func _ready():
	
	var selected_processor = $VBoxContainer/processor/selected_processor
	# if editing a recipe, only show that processor in the list
	if _editing_recipe != null:
		var processor = _editing_recipe.keys()[0]
		var newproc = load(processor).instance()
		selected_processor.add_item(newproc.object_name)
		selected_processor.disabled = true
		
		# add the inputs
		for input in _editing_recipe[processor]["inputs"]:
			_add_input_selected(input)
			
		# add the outputs
		for output in _editing_recipe[processor]["outputs"]:
			_add_output_selected(output)
		
	# otherwise if creating a new recipe, allow any processor to be selected
	else:
		for p in processors:
			selected_processor.add_item(p.object_name)
	
	$VBoxContainer/inputs/button_add_input.connect("pressed", self, "on_add_input_pressed")
	$VBoxContainer/outputs/button_add_output.connect("pressed", self, "on_add_output_pressed")
	$VBoxContainer/save_recipe.connect("pressed", self, "on_save_recipe")
	$VBoxContainer/cancel.connect("pressed", self, "on_cancel")

func _add_input_selected(item_scene):
	if item_scene == null: return
	var newitem = load("res://engine/item_container.gd").new()
	newitem.item = load(item_scene).instance()
	inputs.append(newitem)
	var newitemui = preload("res://ui/item_slot/item_slot.tscn").instance()
	newitemui._item_container = newitem
	newitemui.locked = true
	newitemui.connect("rmb_pressed", self, "_remove_input")
	$VBoxContainer/inputs/inputs_grid.add_child(newitemui)
	
func _remove_input(slot):
	inputs.erase(slot._item_container)
	slot.queue_free()

func _add_output_selected(item_scene):
	if item_scene == null: return
	var newitem = load("res://engine/item_container.gd").new()
	newitem.item = load(item_scene).instance()
	outputs.append(newitem)
	var newitemui = preload("res://ui/item_slot/item_slot.tscn").instance()
	newitemui._item_container = newitem
	newitemui.locked = true
	newitemui.connect("rmb_pressed", self, "_remove_output")
	$VBoxContainer/outputs/outputs_grid.add_child(newitemui)

func _remove_output(slot):
	outputs.erase(slot._item_container)
	slot.queue_free()

func on_add_input_pressed():
	if is_instance_valid(_item_select_menu): return
	var newmenu = _item_select_menu_scene.instance()
	newmenu.connect("item_selected", self, "_add_input_selected")
	newmenu.items = items
	_item_select_menu = newmenu
	_menus.add_child(newmenu)
	
func on_add_output_pressed():
	if is_instance_valid(_item_select_menu): return
	var newmenu = _item_select_menu_scene.instance()
	newmenu.connect("item_selected", self, "_add_output_selected")
	newmenu.items = items
	_item_select_menu = newmenu
	_menus.add_child(newmenu)
	
func on_save_recipe():
	var recipe = {}
	var processor = $VBoxContainer/processor/selected_processor
	recipe["processor"] = processors[processor.get_selected_id()].filename
	recipe["inputs"] = []
	recipe["outputs"] = []
	
	for i in inputs:
		recipe["inputs"].append(i.item.filename)
	for o in outputs:
		recipe["outputs"].append(o.item.filename)
	
	if _editing_recipe != null:
		emit_signal("recipe_edited", _editing_recipe, recipe )
	else: emit_signal("recipe_created", recipe)
	queue_free()
	
func on_cancel():
	queue_free()
