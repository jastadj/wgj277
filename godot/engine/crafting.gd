extends Node

const RECIPE_FILE = "res://data/recipes.json"

var recipes = {}

func _ready():
	recipes = _load_recipes(RECIPE_FILE)
	
func _load_recipes(file_name):
	var file = File.new()
	if file.open(file_name,File.READ):
		printerr("Error loading recipes from file:", file_name)
		return {}
	var json_parse = JSON.parse(file.get_line())
	if json_parse.error != OK:
		printerr("Error parsing json from recipe file:", file_name)
		return {}
	file.close()
	return json_parse.result
	
# process a recipe
# find recipe that at least matches inputs
# consume inputs and place outputs in slots
# return true if successful
func process_recipe(processor, inputs, outputs):
	
	# if recipe for processor doesn't exist, or recipe inputs/outputs empty,return
	if !recipes.has(processor): return false
	if inputs.empty() or outputs.empty(): return false

	# duplicate list of processor's recipes
	# this list will be whittled down to possible recipes
	var processor_recipes = recipes[processor].duplicate()
	var selected_recipe = null
	
	# remove input item containers that are empty, can ignore those
	for input in inputs:
		if input.empty(): inputs.erase(input)
	# if there are no inputs left, return
	if inputs.empty(): return false
	
	# remove recipes that don't include any of the inputs,
	# AND don't have enough stack size input
	for recipe in processor_recipes:
		for input in inputs:
			var input_scene = input.item.filename
			var input_stack = input.item.stack
			# if recipe doesn't have an input ingredient, exclude it
			if !recipe["inputs"].has(input_scene):
				processor_recipes.erase(recipe)
			# otherwas if has input, make sure stack size is satisfied
			elif input_stack < recipe["inputs"][input_scene]:
				processor_recipes.erase(recipe)
	
	# no recipes found?
	if processor_recipes.empty(): return false
	
	# find recipe that is satisfied by inputs
	for recipe in processor_recipes:
		var my_inputs = inputs.duplicate()
		var recipe_satisfied = true
		
		for input in recipe["inputs"]:
			for my_input in my_inputs:		
				var myinput_scene = my_input.item.filename
				var myinput_stack = my_input.item.stack
				if myinput_scene == input and myinput_stack >= recipe["inputs"][input]:
					my_inputs.erase(my_input)
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
				# if input ingredient found, reduce the stack
				if my_input.item.filename == input:
					my_input.decrement_stack(selected_recipe["inputs"][input])
					break
	for output in selected_recipe["outputs"]:
		var output_satisfied = false
		# check for like items to stack first
		for my_output in outputs:
			if !my_output.empty():
				if my_output.item.filename == output:
					my_output.increment_stack(selected_recipe["outputs"][output])
					output_satisfied = true
					break
		if !output_satisfied:
			for my_output in outputs:
				if my_output.empty():
					output_satisfied = true
					var output_item = load(output).instance()
					output_item.stack = selected_recipe["outputs"][output]
					my_output.add_item(output_item)
					break
		
	return true
	
