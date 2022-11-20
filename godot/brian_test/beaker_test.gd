extends Node2D

export(float) var percent = 0.5
export(Color) var color = Color.white

onready var bottom_y = $bottom.position.y
onready var top_y = $top.position.y
var original_fill_region

var _height

var _debug = false

func _ready():
	
	# get the height of the fill when at 100%
	_height = bottom_y - top_y
	# get the original fill sprite's texture region
	original_fill_region = $fill.region_rect
	
	if is_inside_tree():
		# if we are testing this scene, move it away from center
		# and add a slider we can use to test the percent
		if get_tree().current_scene == self:
			_debug = true
			position = Vector2(90,90)
			var slider = HSlider.new()
			var new_canvas = CanvasLayer.new()
			add_child(new_canvas)
			new_canvas.add_child(slider)
			slider.rect_min_size.x = 100
			slider.min_value = 0.0
			slider.max_value = 1.0
			slider.step = 0.01
			slider.value = 1.0
			slider.connect("value_changed", self, "set_percent")

	# set the color of the contents
	$fill.self_modulate = color
	$top.self_modulate = color
	$bottom.self_modulate = color
	
func _process(delta):
	
	# keep the percent between 0 and 1 (0 - 100%)
	percent = clamp(percent, 0.0, 1.0)
	# adjust the top part's y position based on the percent of the total height
	$top.position.y = bottom_y - (_height*percent)
	# if we are 0%, dont draw any contents
	$top.visible = (percent > 0.0)
	$bottom.visible = (percent > 0.0)
	$fill.visible = (percent > 0.0)
	
	# adjust the fill's texture region based on fill %
	$fill.region_rect.size = Vector2(original_fill_region.size.x, _height*percent)
	$fill.region_rect.position = Vector2(original_fill_region.position.x, original_fill_region.position.y + (_height - (_height*percent)))
	$fill.position.y = $top.position.y
		
func set_percent(value):
	percent = value
