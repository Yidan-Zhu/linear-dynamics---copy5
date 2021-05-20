extends Line2D

# sliders
onready var slider00 = $HSlider00
onready var slider01 = $HSlider01
onready var slider10 = $HSlider10
onready var slider11 = $HSlider11
var slider_shift_x = 200

onready var text00 = get_node("HSlider00/Label00")
onready var text01 = get_node("HSlider01/Label01")
onready var text10 = get_node("HSlider10/Label10")
onready var text11 = get_node("HSlider11/Label11")

var transform_matrix = Transform2D()
var old_matrix = Transform2D()

# other
var color_title = Color(0,32.0/255.0,96.0/255.0,1)
var center_of_drawing = Vector2(550,310)
var box_region_half_width = 100
var color_line = Color(0.91,0.235,0.635,1.0)
var checkbox_pos = Vector2(635,170)	
var color_checkbox = Color(1,1,1,0.4)

###################################################

func _ready():
	# title
	if !get_node_or_null("title"):
		var node = Label.new()
		node.name = "title"
		add_child(node)	
	get_node("title").set_global_position(Vector2(445,530))
	get_node("title").text = "Discrete Linear Dynamics"
	
	var dynamic_font_3 = DynamicFont.new()
	dynamic_font_3.font_data = load("res://Fonts/BebasNeue_Bold.ttf")
	dynamic_font_3.size = 25

	get_node("title").add_color_override("font_color", color_title)
	get_node("title").add_font_override("font",dynamic_font_3)	

	# initialize the sliders
	slider00.set_global_position(Vector2(200+slider_shift_x,50))
	slider00.rect_size = Vector2(100,16)
	slider00.min_value = -1
	slider00.max_value = 1
	slider00.step = 0.01
	slider00.value = 0.6

	slider01.set_global_position(Vector2(410+slider_shift_x,50))
	slider01.rect_size = Vector2(100,16)
	slider01.min_value = -1
	slider01.max_value = 1
	slider01.step = 0.01
	slider01.value = 0.5

	slider10.set_global_position(Vector2(200+slider_shift_x,100))
	slider10.rect_size = Vector2(100,16)
	slider10.min_value = -1
	slider10.max_value = 1
	slider10.step = 0.01
	slider10.value = 0.3
	
	slider11.set_global_position(Vector2(410+slider_shift_x,100))
	slider11.rect_size = Vector2(100,16)
	slider11.min_value = -1
	slider11.max_value = 1
	slider11.step = 0.01
	slider11.value = -0.6		

	var dynamic_font = DynamicFont.new()
	dynamic_font.font_data = load("res://Fonts/BebasNeue_Bold.ttf")
	dynamic_font.size = 20

	text00.set_position(Vector2(slider00.rect_size.x+20,10))
	text00.text = str(slider00.value)
	text00.add_color_override("font_color",ColorN("Black"))
	text00.add_font_override("font",dynamic_font)	

	text01.set_position(Vector2(-50,10))
	text01.text = str(slider01.value)
	text01.add_color_override("font_color",ColorN("Black"))
	text01.add_font_override("font",dynamic_font)
	
	text10.set_position(Vector2(slider10.rect_size.x+20,-10))
	text10.text = str(slider10.value)
	text10.add_color_override("font_color",ColorN("Black"))
	text10.add_font_override("font",dynamic_font)

	text11.set_position(Vector2(-50,-10))
	text11.text = str(slider11.value)
	text11.add_color_override("font_color",ColorN("Black"))
	text11.add_font_override("font",dynamic_font)

	var dynamic_font_2 = DynamicFont.new()
	dynamic_font_2.font_data = load("res://Fonts/BebasNeue_Bold.ttf")
	dynamic_font_2.size = 15

func _process(delta):
	# update the matrix and eigens
	transform_matrix.x.x = slider00.value
	transform_matrix.x.y = slider01.value
	transform_matrix.y.x = slider10.value
	transform_matrix.y.y = slider11.value	

	# update when the matrix is updated
	if transform_matrix != old_matrix:
		old_matrix = transform_matrix
		text00.text = str(stepify(sinh(slider00.value),0.1))
		text01.text = str(stepify(sinh(slider01.value),0.1))
		text10.text = str(stepify(sinh(slider10.value),0.1))
		text11.text = str(stepify(sinh(slider11.value),0.1))

func _draw():
# draw a box for matrix	
	draw_rect(Rect2(slider00.rect_position.x + text00.rect_position.x - 5, \
		slider00.rect_position.y + text00.rect_position.y-5, 80,56),\
		Color(1, 1, 1, 1), 1.0, true)

# draw a box for initial points
	draw_line(Vector2(center_of_drawing.x-box_region_half_width,center_of_drawing.y-box_region_half_width),\
		Vector2(center_of_drawing.x+box_region_half_width, center_of_drawing.y-box_region_half_width),\
		color_line, 1.0, true)

	draw_line(Vector2(center_of_drawing.x-box_region_half_width,center_of_drawing.y-box_region_half_width),\
		Vector2(center_of_drawing.x-box_region_half_width, center_of_drawing.y+box_region_half_width),\
		color_line, 1.0, true)

	draw_line(Vector2(center_of_drawing.x+box_region_half_width,center_of_drawing.y-box_region_half_width),\
		Vector2(center_of_drawing.x+box_region_half_width, center_of_drawing.y+box_region_half_width),\
		color_line, 1.0, true)

	draw_line(Vector2(center_of_drawing.x-box_region_half_width,center_of_drawing.y+box_region_half_width),\
		Vector2(center_of_drawing.x+box_region_half_width, center_of_drawing.y+box_region_half_width),\
		color_line, 1.0, true)

# a checkbox for vector field
	draw_rect(Rect2(checkbox_pos.x,checkbox_pos.y,15,15), color_checkbox, true)

	if !get_node_or_null("check_box"):
		var node = Label.new()
		node.name = "check_box"
		add_child(node)	
	get_node("check_box").set_global_position(checkbox_pos+Vector2(17.5,2))		
	get_node("check_box").text = "Vector Field"
	get_node("check_box").add_color_override("font_color", Color(0,0,0,1))
