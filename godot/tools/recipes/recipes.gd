extends Node2D

var recipe_file = Crafting.RECIPE_FILE
var processors = []
var items = []
var recipes = {}
onready var menus = $CanvasLayer/main_ui/menus

func _ready():
	
	# load recipes from gamedata
	recipes = Crafting.recipes
	
	# create list of processors
	for p in $_processors.get_children():
		processors.append(p)
	
	# create list of items
	for i in $_items.get_children():
		items.append(i)
	
	$CanvasLayer/main_ui/buttons/button_create_recipe.connect("pressed", self, "create_recipe")
	$CanvasLayer/main_ui/buttons/button_save_recipes.connect("pressed", self, "save_recipes")
	$CanvasLayer/main_ui/buttons/button_items.connect("pressed", self, "item_select_test")
	$CanvasLayer/main_ui/buttons/button_main_menu.connect("pressed", get_tree(), "change_scene", ["res://scenes/main_menu/main_menu.tscn"])
	
	update_recipe_list()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if menus_open():
			$CanvasLayer/main_ui/menus.get_children().back().queue_free()
		else:
			get_tree().quit()

func menus_open():
	if $CanvasLayer/main_ui/menus.get_child_count() > 0: return true
	return false

func create_recipe():
	if menus_open(): return
	var newmenu = preload("res://tools/recipes/recipe_editor.tscn").instance()
	newmenu.connect("recipe_created", self, "_on_recipe_created")
	$CanvasLayer/main_ui/menus.add_child(newmenu)

func save_recipes():
	var file = File.new()
	if file.open(recipe_file, File.WRITE):
		printerr("Error saving recipes, unable to open ",recipe_file)
		return false
	file.store_string(to_json(recipes))
	file.close()
	print("saved recipes:", recipes)
	return true

func _on_recipe_created(recipe):
	print("created recipe:", recipe)
	var processor = recipe["processor"]
	recipe.erase("processor")
	if !recipes.has(processor):
		recipes[processor] = []
	recipes[processor].append(recipe)
	update_recipe_list()

func _on_recipe_edited(original_recipe, new_recipe):
	var processor = original_recipe.keys()[0]
	# find the original recipe
	for recipe in recipes[processor]:
		if recipe == original_recipe[processor]:
			recipe.merge(new_recipe, true)
			print("Recipe updated.")
			update_recipe_list()
			return
	

func item_select_test():
	if menus_open(): return
	var newmenu = preload("res://tools/recipes/item_Selector.tscn").instance()
	newmenu.items = items
	$CanvasLayer/main_ui/menus.add_child(newmenu)

func update_recipe_list():
	var recipe_list = $CanvasLayer/main_ui/recipes_panel/ScrollContainer/recipe_list
	var recipe_entry = $CanvasLayer/main_ui/recipes_panel/a_recipe
	
	# clear list
	for c in recipe_list.get_children():
		recipe_list.remove_child(c)
		c.queue_free()
	
	# create entries from recipes
	for processor in recipes.keys():
		var processor_instance = load(processor).instance()
		var processor_name = processor_instance.object_name
		
		# for each recipe of the processor, create an entry
		for recipe in recipes[processor]:
			var newentry = recipe_entry.duplicate()
			newentry.visible = true
			newentry.get_node("processor").text = processor_name
			# connect buttons
			newentry.get_node("delete").connect("pressed", self, "on_delete_recipe", [processor, recipe])
			newentry.get_node("edit").connect("pressed", self, "on_edit_recipe", [processor, recipe])
			
			# crafting time
			newentry.get_node("time").text = str("Time:", recipe["time"])
			
			#inputs
			for input in recipe["inputs"]:
				# create item, container, and ui slot
				var newcontainer = load("res://engine/item_container.gd").new()
				var newslot = preload("res://ui/item_slot/item_slot.tscn").instance()
				var inputitem = load(input).instance()
				newslot._item_container = newcontainer
				inputitem.stack = recipe["inputs"][input]
				newcontainer.add_item(inputitem)
				newslot.locked = true
				newentry.get_node("input_list").add_child(newslot)
			# outputs
			for output in recipe["outputs"]:
				# create item, container, and ui slot
				var newcontainer = load("res://engine/item_container.gd").new()
				var newslot = preload("res://ui/item_slot/item_slot.tscn").instance()
				var outputitem = load(output).instance()
				newslot._item_container = newcontainer
				outputitem.stack = recipe["outputs"][output]
				newcontainer.add_item(outputitem)
				newslot.locked = true
				newentry.get_node("output_list").add_child(newslot)
			# add entry to recipe list
			recipe_list.add_child(newentry)

func on_delete_recipe(processor, recipe):
	for precipes in recipes[processor]:
		if precipes == recipe:
			recipes[processor].erase(precipes)
			update_recipe_list()
			return true
	return false

func on_edit_recipe(processor, recipe):
	var newmenu = preload("res://tools/recipes/recipe_editor.tscn").instance()
	newmenu._editing_recipe = {processor:recipe}
	newmenu.connect("recipe_edited", self, "_on_recipe_edited")
	$CanvasLayer/main_ui/menus.add_child(newmenu)
