extends Line2D

# axes
export var origin = Vector2(200,450)
export var x_axis_length = Vector2(110,0)
export var y_axis_length = Vector2(0,110)
# axis labels
var x_label_adjust = Vector2(0,10)
var y_label_adjust = Vector2(10,10)
var y_tick_label_adjust = Vector2(-21,-6)
# ticks
var x_scale_length = Vector2(0,-5)
var y_scale_length = Vector2(5,0) 
export var x_max_number = 2
export var y_max_number = 2
# scale info
export var x_scale_width = Vector2(50,0)   # x : 50 pixel = 0.5
export var y_scale_width = Vector2(0,50)   # y : 50 pixel = 0.5

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

# draw a unit circle for normalized real eigenvecs
	draw_concentric_circle(origin, x_max_number*x_scale_width.x, \
		1.2, Color(0,0,0,0.1))	

# set axes text
	var dynamic_font = DynamicFont.new()
	dynamic_font.font_data = load("res://Fonts/BebasNeue_Bold.ttf")
	dynamic_font.size = 18
	
	var x_axis_text = get_node("Label_x_axis")
	x_axis_text.set_global_position(origin+x_axis_length + x_label_adjust)
	x_axis_text.text = "x"
	x_axis_text.add_font_override("font",dynamic_font)
	var y_axis_text = get_node("Label_y_axis")
	y_axis_text.set_global_position(origin-y_axis_length - y_label_adjust - x_label_adjust)
	y_axis_text.text = "y"
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
	
	if !get_node_or_null("../Label2_(" + str(0)):
		var node = Label.new()
		node.name = "Label2_(" + str(0)
		get_parent().add_child(node)	
	get_node("../Label2_(" + str(0)).set_global_position(\
		origin + x_label_adjust+Vector2(-14,-3))
	get_node("../Label2_(" + str(0)).text = str(0)
	get_node("../Label2_(" + str(0)).add_font_override("font",dynamic_font_2)

	if !get_node_or_null("../Label2_posx"):
		var node = Label.new()
		node.name = "Label2_posx"
		get_parent().add_child(node)	
	get_node("../Label2_posx").set_global_position(\
		origin+x_max_number*x_scale_width + x_label_adjust+Vector2(-5,0))
	get_node("../Label2_posx").text = str(1)
	get_node("../Label2_posx").add_font_override("font",dynamic_font_2)
		
	if !get_node_or_null("../Label2_negx"):
		var node = Label.new()
		node.name = "Label2_negx"
		get_parent().add_child(node)	
	get_node("../Label2_negx").set_global_position(\
		origin+(-x_max_number)*x_scale_width + x_label_adjust+Vector2(-10,0))
	get_node("../Label2_negx").text = str(-1)
	get_node("../Label2_negx").add_font_override("font",dynamic_font_2)

	if !get_node_or_null("../Label2_(" + str(y_max_number)):
		var node = Label.new()
		node.name = "Label2_(" + str(y_max_number)
		get_parent().add_child(node)	
	get_node("../Label2_(" + str(y_max_number)).set_global_position(\
		origin-y_max_number*y_scale_width + y_tick_label_adjust+Vector2(5,0))
	get_node("../Label2_(" + str(y_max_number)).text = str(1)
	get_node("../Label2_(" + str(y_max_number)).add_font_override("font",dynamic_font_2)

	if !get_node_or_null("../Label2_(" + str(-y_max_number)):
		var node = Label.new()
		node.name = "Label2_(" + str(-y_max_number)
		get_parent().add_child(node)	
	get_node("../Label2_(" + str(-y_max_number)).set_global_position(\
		origin+y_max_number*y_scale_width + y_tick_label_adjust)
	get_node("../Label2_(" + str(-y_max_number)).text = str(-1)
	get_node("../Label2_(" + str(-y_max_number)).add_font_override("font",dynamic_font_2)
		
################################################################################
# define a triangle arrow drawing function
func draw_triangle(pos, dir, size):
	dir = dir.normalized()
	var a = pos + dir*size
	var b = pos + dir.rotated(2*PI/3)*size
	var c = pos + dir.rotated(4*PI/3)*size
	var points = PoolVector2Array([a,b,c])
	draw_polygon(points, PoolColorArray([Color(0,0,0)]))

func draw_concentric_circle(center, radius, linewidth, color):
	var number_of_points = 199
	var step = PI/number_of_points
	var circle_x
	var circle_y
	var next_x
	var next_y
	for i in range(number_of_points):
		circle_x = radius*cos(step*i)
		circle_y = -radius*sin(step*i)
		next_x = radius*cos(step*(i+1))
		next_y = -radius*sin(step*(i+1))
		draw_line(center+Vector2(circle_x,circle_y),center+Vector2(next_x,next_y),\
			color,linewidth,true)
	for i in range(number_of_points):
		circle_x = radius*cos(step*i)
		circle_y = radius*sin(step*i)
		next_x = radius*cos(step*(i+1))
		next_y = radius*sin(step*(i+1))
		draw_line(center+Vector2(circle_x,circle_y),center+Vector2(next_x,next_y),\
			color,linewidth,true)
