extends Node2D

var processors = []
var items = []
onready var menus = $CanvasLayer/main_ui/menus

func _ready():
	
	# create list of processors
	for p in $_processors.get_children():
		processors.append(p.object_name)
	
	# create list of items
	for i in $_items.get_children():
		items.append(i)
	
	$CanvasLayer/main_ui/buttons/button_create_recipe.connect("pressed", self, "create_recipe")
	$CanvasLayer/main_ui/buttons/button_items.connect("pressed", self, "item_select_test")

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
	$CanvasLayer/main_ui/menus.add_child(newmenu)

func item_select_test():
	if menus_open(): return
	var newmenu = preload("res://tools/recipes/item_Selector.tscn").instance()
	newmenu.items = items
	$CanvasLayer/main_ui/menus.add_child(newmenu)
