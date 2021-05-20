extends Line2D

# axes
export var origin = Vector2(200,180)
export var x_axis_length = Vector2(110,0)
export var y_axis_length = Vector2(0,110)
# axis labels
var x_label_adjust = Vector2(0,10)
var y_label_adjust = Vector2(30,14)
var y_tick_label_adjust = Vector2(-21,-6)
# ticks
var x_scale_length = Vector2(0,-5)
var y_scale_length = Vector2(5,0) 
export var x_max_number = 4
export var y_max_number = 4
# scale info
export var x_scale_width = Vector2(25,0)   # x : 25 pixel = 0.5
export var y_scale_width = Vector2(0,25)   # y : 25 pixel = 0.5

#######################################################

func _ready():
	pass

func _draw():
# draw axis lines and arrows
	draw_line(origin, origin+x_axis_length,ColorN("Black"),1.0, true)
	draw_line(origin, origin-x_axis_length,ColorN("Black"),1.0, true)
	draw_line(origin, origin-y_axis_length,ColorN("Black"),1.0, true)
	draw_line(origin, origin+y_axis_length,ColorN("Black"),1.0, true)
	
	draw_triangle(origin+x_axis_length, Vector2(1,0),5)
	draw_triangle(origin-x_axis_length, Vector2(-1,0),5)
	draw_triangle(origin-y_axis_length, Vector2(0,-1),5)
	draw_triangle(origin+y_axis_length, Vector2(0,1),5)

# set axes text
	var dynamic_font = DynamicFont.new()
	dynamic_font.font_data = load("res://Fonts/BebasNeue_Bold.ttf")
	dynamic_font.size = 18
	
	var x_axis_text = get_node("Label_x_axis")
	x_axis_text.set_global_position(origin+x_axis_length + x_label_adjust)
	x_axis_text.text = "Real"
	x_axis_text.add_font_override("font",dynamic_font)
	var y_axis_text = get_node("Label_y_axis")
	y_axis_text.set_global_position(origin-y_axis_length - y_label_adjust - x_label_adjust)
	y_axis_text.text = "Imaginary"
	y_axis_text.add_font_override("font",dynamic_font)

# draw axis ticks
	for n in range(x_max_number):
		draw_line(origin+(n+1)*x_scale_width,\
			origin+(n+1)*x_scale_width-x_scale_length, \
			ColorN("Black"),1.0, true)
		draw_line(origin-(n+1)*x_scale_width,origin-(n+1)*x_scale_width-x_scale_length, \
			ColorN("Black"),1.0, true)

	for n in range(1, y_max_number+1):
		var y_tick = Vector2(origin.x, origin.y - n*y_scale_width.y)
		draw_line(y_tick, y_tick - y_scale_length, ColorN("Black"),1.0, true)
		y_tick = Vector2(origin.x, origin.y + n*y_scale_width.y)
		draw_line(y_tick, y_tick - y_scale_length, ColorN("Black"),1.0, true)

# add tick text
	var dynamic_font_2 = DynamicFont.new()
	dynamic_font_2.font_data = load("res://Fonts/BebasNeue_Bold.ttf")
	dynamic_font_2.size = 15
	
	if !get_node_or_null("../Label_(" + str(0)):
		var node = Label.new()
		node.name = "Label_(" + str(0)
		get_parent().add_child(node)	
	get_node("../Label_(" + str(0)).set_global_position(\
		origin + x_label_adjust+Vector2(-14,-3))
	get_node("../Label_(" + str(0)).text = str(0)
	get_node("../Label_(" + str(0)).add_font_override("font",dynamic_font_2)

	if !get_node_or_null("../Label_posx"):
		var node = Label.new()
		node.name = "Label_posx"
		get_parent().add_child(node)	
	get_node("../Label_posx").set_global_position(\
		origin+x_max_number*x_scale_width + x_label_adjust+Vector2(-5,0))
	get_node("../Label_posx").text = str(2)
	get_node("../Label_posx").add_font_override("font",dynamic_font_2)
		
	if !get_node_or_null("../Label_negx"):
		var node = Label.new()
		node.name = "Label_negx"
		get_parent().add_child(node)	
	get_node("../Label_negx").set_global_position(\
		origin+(-x_max_number)*x_scale_width + x_label_adjust+Vector2(-10,0))
	get_node("../Label_negx").text = str(-2)
	get_node("../Label_negx").add_font_override("font",dynamic_font_2)

	if !get_node_or_null("../Label_(" + str(y_max_number)):
		var node = Label.new()
		node.name = "Label_(" + str(y_max_number)
		get_parent().add_child(node)	
	get_node("../Label_(" + str(y_max_number)).set_global_position(\
		origin-y_max_number*y_scale_width + y_tick_label_adjust+Vector2(5,0))
	get_node("../Label_(" + str(y_max_number)).text = str(2)
	get_node("../Label_(" + str(y_max_number)).add_font_override("font",dynamic_font_2)

	if !get_node_or_null("../Label_(" + str(-y_max_number)):
		var node = Label.new()
		node.name = "Label_(" + str(-y_max_number)
		get_parent().add_child(node)	
	get_node("../Label_(" + str(-y_max_number)).set_global_position(\
		origin+y_max_number*y_scale_width + y_tick_label_adjust)
	get_node("../Label_(" + str(-y_max_number)).text = str(-2)
	get_node("../Label_(" + str(-y_max_number)).add_font_override("font",dynamic_font_2)
		
################################################################################
# define a triangle arrow drawing function
func draw_triangle(pos, dir, size):
	dir = dir.normalized()
	var a = pos + dir*size
	var b = pos + dir.rotated(2*PI/3)*size
	var c = pos + dir.rotated(4*PI/3)*size
	var points = PoolVector2Array([a,b,c])
	draw_polygon(points, PoolColorArray([Color(0,0,0)]))
