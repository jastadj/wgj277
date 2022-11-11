extends PanelContainer

const tooltip_offset = Vector2(24, 0)

var item = null

func _ready():
	
	var property_label = $VBoxContainer/properties.get_child(0)
	$VBoxContainer/properties.remove_child(property_label)
	
	if item != null:
		
		# item name and description
		$VBoxContainer/item_name.text = item.object_name
		$VBoxContainer/item_description.text = item.object_description
		
		# properties (is an ingredient, a product, etc)
		if item.is_ingredient():
			var new_label = property_label.duplicate()
			new_label.text = "Ingredient"
			new_label.name = "ingredient"
			$VBoxContainer/properties.add_child(new_label)
		if item.is_product():
			var new_label = property_label.duplicate()
			new_label.text = "Craftable"
			new_label.name = "craftable"
			$VBoxContainer/properties.add_child(new_label)			
	
func _process(delta):
	
	set_global_position(get_global_mouse_position() + Vector2(0, -rect_size.y) + tooltip_offset)
