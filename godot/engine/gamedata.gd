extends Node

var message_queue = []
onready var recipes = load_recipes("res://data/recipes.json")
onready var background_container = load("res://engine/item_container.gd").new()

func _ready():
	
	# init forbidden mouse cursor
	# this is to hide the mouse cursor when drag and drop is forbidden
	var forbidden_cursor_image = Image.new()
	var forbidden_cursor = ImageTexture.new()
	forbidden_cursor_image.create(8,8,false,Image.FORMAT_RGBA8)
	forbidden_cursor_image.fill(Color(1,1,1,0.01))
	forbidden_cursor.create_from_image(forbidden_cursor_image)
	Input.set_custom_mouse_cursor(forbidden_cursor, Input.CURSOR_FORBIDDEN)

func load_recipes(tfilename):
	var recipesdict = {}
	var file = File.new()
	if file.open(tfilename,File.READ):
		printerr("Error loading recipes from file:", tfilename)
		return recipesdict
	recipesdict = JSON.parse(file.get_line()).result
	file.close()
	return recipesdict

func process_recipe(processor, inputs, outputs):
	
	if !recipes.has(processor): return false
	if inputs.empty() or outputs.empty(): return false
	
	var processor_recipes = recipes[processor].duplicate()
	var selected_recipe = null
	
	# remove inputs that are empty
	for input in inputs:
		if input.empty(): inputs.erase(input)
	if inputs.empty(): return false
	
	# remove recipes that don't include any of the inputs
	for recipe in processor_recipes:
		for input in inputs:
			if !recipe["inputs"].has(input.item.filename): processor_recipes.erase(recipe)
	
	# no recipes found?
	if processor_recipes.empty(): return false
	
	# find recipe that is satisfied by inputs
	for recipe in processor_recipes:
		var my_inputs = inputs.duplicate()
		var recipe_satisfied = true
		for input in recipe["inputs"]:
			for my_input in my_inputs:
				if my_input.item.filename == input: my_inputs.erase(my_input)
				else: recipe_satisfied = false
		# if my_inputs list is empty and the satisfied flag is ticked
		# then select this recipe for processing
		if my_inputs.empty() and recipe_satisfied:
			selected_recipe = recipe
			break
			
	# if no recipe has been found, return
	if selected_recipe == null: return false
	
	# make sure either the output slots are empty or contain the same product
	var my_outputs = outputs.duplicate()
	for output in selected_recipe["outputs"]:
		var output_satisfied = false
		# check to see if any output slot already contains the product
		for my_output in my_outputs:
			if !my_output.empty():
				if my_output.item.filename == output:
					output_satisfied = true
		# check for an empty output
		if !output_satisfied:
			for my_output in my_outputs:
				if my_output.empty():
					output_satisfied = true
					my_outputs.erase(my_output)
		# output still isn't satisfied, bail
		if !output_satisfied:
			return false
	
	# craft the recipe
	for input in selected_recipe["inputs"]:
		for my_input in inputs:
			if !my_input.empty():
				if my_input.item.filename == input:
					my_input.remove_item().queue_free()
					break
	for output in selected_recipe["outputs"]:
		var output_satisfied = false
		# check for like items to stack first
		for my_output in outputs:
			if !my_output.empty():
				if my_output.item.filename == output:
					my_output.item.stack += 1
					output_satisfied = true
					break
		if !output_satisfied:
			for my_output in outputs:
				if my_output.empty():
					output_satisfied = true
					my_output.add_item(load(output).instance())
					break
		
	return true
	

func add_message(msg):
	message_queue.push_back(msg)
	
func on_tree_changed():
	print("tree changed")
