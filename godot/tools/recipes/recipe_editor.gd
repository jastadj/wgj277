extends PanelContainer

onready var items = get_tree().current_scene.items
onready var processors = get_tree().current_scene.processors
onready var input_list = $VBoxContainer/inputs/input_list
onready var output_list = $VBoxContainer/outputs/output_list

var _item_select_menu = null
var _item_select_menu_scene = preload("res://tools/recipes/item_Selector.tscn")
onready var _menus = get_tree().current_scene.menus
var _editing_recipe = null # used to indicate if editing an existing recipe, null for new recipe

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

func increment_ingredient_entry(list, item_scene):
	if item_scene == null: return false
	for ingredient in list.get_children():
		if ingredient.get_item_scene() == item_scene:
			ingredient.increment_stack()
			return true
	return false

func create_ingredient_entry(item_scene):
	var new_entry = preload("res://tools/recipes/ingredient_entry.tscn").instance()
	new_entry.set_item_by_scene(item_scene)
	new_entry.connect("rmb_pressed", self, "_remove_entry", [new_entry])
	return new_entry

func _add_input_selected(item_scene):
	# if unable to find and increment an ingredient, create new entry
	if !increment_ingredient_entry(input_list, item_scene):
		input_list.add_child(create_ingredient_entry(item_scene))
	
func _add_output_selected(item_scene):
	# if unable to find and increment an ingredient, create new entry
	if !increment_ingredient_entry(output_list, item_scene):
		output_list.add_child(create_ingredient_entry(item_scene))

func _remove_entry(ingredient):
	ingredient.get_parent().remove_child(ingredient)
	ingredient.queue_free()

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
	
	var processor = $VBoxContainer/processor/selected_processor
	
	# create recipe dictionary
	var recipe = {}
	recipe["processor"] = processors[processor.get_selected_id()].filename
	recipe["inputs"] = {}
	recipe["outputs"] = {}
	
	# collect inputs and outputs
	for i in input_list.get_children():
		recipe["inputs"][i.get_item_scene()] = i.get_stack_size()
	for o in output_list.get_children():
		recipe["outputs"][o.get_item_scene()] = o.get_stack_size()
	
	if _editing_recipe != null:
		emit_signal("recipe_edited", _editing_recipe, recipe )
	else: emit_signal("recipe_created", recipe)
	queue_free()
	
func on_cancel():
	queue_free()
