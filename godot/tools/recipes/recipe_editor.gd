extends PanelContainer

func _ready():
	
	for p in get_tree().current_scene.processors:
		$VBoxContainer/processor/selected_processor.add_item(p)
