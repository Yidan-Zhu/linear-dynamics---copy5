extends Line2D

#####################
#       PARAM
#####################
# random initial points
var initial_points = Array()
var rng = RandomNumberGenerator.new()
var transform_matrix = Transform2D()
var old_matrix = Transform2D()
var box_region_half_width = 100
var number_of_intervals = 10*4

# draw evolution 
var center_of_drawing = Vector2(550,310)
var color_line = Color(0.91,0.235,0.635,1.0)
var color_evolution_states = Color(0.92, 0.76, 0.196,1.0)
var color_initial_points = Color(230.0/255.0, 79.0/255.0, 127.0/255.0, 1.0)

onready var timer = get_node("Timer_draw_evolution")
onready var wait_timer = get_node("Timer2_wait")
var animation_wait_time = 0.55 # in seconds
var evolution_state_number = 8 # how many steps to draw
var evolution_step = 1
var first_wait = true
var first_tick = false
var still_time = 1.5

# transformation calculation
var vector_start 
var state_next

# matrix
onready var slider00 = get_node("Line2D_Slider/HSlider00")
onready var slider01 = $Line2D_Slider/HSlider01
onready var slider10 = $Line2D_Slider/HSlider10
onready var slider11 = $Line2D_Slider/HSlider11

# checkbox
export var vector_flag = false
var checkbox_pos = Vector2(635,170)
var events = {}

##############################################################

func _ready():
	rng.randomize()
	for j in range(number_of_intervals):
		initial_points.append(generate_points(j,number_of_intervals))
		
####################################################

func _process(_delta):
	# update the matrix and eigens
	transform_matrix.x.x = stepify(sinh(slider00.value),0.1)
	transform_matrix.x.y = stepify(sinh(slider01.value),0.1)
	transform_matrix.y.x = stepify(sinh(slider10.value),0.1)
	transform_matrix.y.y = stepify(sinh(slider11.value),0.1)
	
	if transform_matrix != old_matrix:
		evolution_step = 1
		old_matrix = transform_matrix

	update()

#################################################

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			events[event.index] = event
		else:
			events.erase(event.index)
	
	if event.position.x <= checkbox_pos.x+15 and \
	   event.position.x >= checkbox_pos.x and \
	   event.position.y >= checkbox_pos.y and \
	   event.position.y <= checkbox_pos.y+15:
		if event is InputEventScreenTouch and events.size() == 1:
			vector_flag = !vector_flag
			evolution_step = 1
			update()
			if vector_flag:
				first_tick = true

################################################
		
func _draw():	
# draw a √ if noise == true.
	if vector_flag:
		draw_a_tick(checkbox_pos+Vector2(7,12))
	
# Get the random points and draw evolution paths
	for j in range(number_of_intervals):
		vector_start = initial_points[j]	
		vector_start.y = -vector_start.y
		draw_circle(center_of_drawing + vector_start, 3.0, color_initial_points)

		if vector_flag == false: # no vector field
			timer.stop()
			for _k in range(evolution_state_number):  # number of states for each
				state_next = the_next_state(transform_matrix, vector_start)
				state_next.y = -state_next.y
				draw_circle(state_next + center_of_drawing, 2.0, color_evolution_states)
				draw_line(center_of_drawing+vector_start, \
					center_of_drawing+state_next,\
					color_line, 1.0, true)
				vector_start = state_next	
				
		elif vector_flag and first_tick: # with vector field
			timer.set_wait_time(animation_wait_time)	
			timer.start()   
			first_tick = false

		for k in range(2,evolution_state_number+2):  # number of states for each
			if evolution_step == k:
				for _i in range(k-1):
					state_next = the_next_state(transform_matrix, vector_start)
					state_next.y = -state_next.y
					draw_circle(state_next + center_of_drawing, 2.0, color_evolution_states)
					draw_line(center_of_drawing+vector_start, \
						center_of_drawing+state_next,\
						color_line, 1.0, true)
					vector_start = state_next	
			
#################################################################

# define a triangle drawing function
func draw_triangle(pos, dir, size, color):
	dir = dir.normalized()
	var a = pos + dir*size
	var b = pos + dir.rotated(2*PI/3)*size
	var c = pos + dir.rotated(4*PI/3)*size
	var points = PoolVector2Array([a,b,c])
	draw_polygon(points, PoolColorArray([color]))

# Genrate random initial points
func generate_points(interval_number, total_interval):  
	# intervals to make the random points not congesting together
	# rectangluar boxes for each point.
	var each_interval_x_length = 2.0*box_region_half_width/(total_interval/4)
	var my_random_numberx
	var my_random_numbery
	if interval_number < total_interval/4:
		#var my_random_numberx = rng.randf_range(\
		#	-box_region_half_width+each_interval_x_length*interval_number,\
		#	-box_region_half_width+each_interval_x_length*(interval_number+1))
		#var my_random_numbery = rng.randf_range(-box_region_half_width,\
			#box_region_half_width)
		my_random_numberx = -box_region_half_width+each_interval_x_length*interval_number
		my_random_numbery = box_region_half_width
		
	elif interval_number >= total_interval/4 and \
		interval_number < total_interval*2/4:
		my_random_numberx = -box_region_half_width+each_interval_x_length*(interval_number-total_interval/4)
		my_random_numbery = -box_region_half_width
		
	elif interval_number >= total_interval*2/4 and \
		interval_number < total_interval*3/4:
		my_random_numberx = -box_region_half_width
		my_random_numbery = box_region_half_width-each_interval_x_length*(interval_number-total_interval*2/4)
		
	else:
		my_random_numberx = box_region_half_width
		my_random_numbery = box_region_half_width-each_interval_x_length*(interval_number-total_interval*3/4)	
		
	return Vector2(my_random_numberx, my_random_numbery)

# calculate evolution state
func the_next_state(matrix, current_pos):
	var next_pos_x = matrix.x.x*current_pos.x + matrix.x.y*current_pos.y
	var next_pos_y = matrix.y.x*current_pos.x + matrix.y.y*current_pos.y
	return Vector2(next_pos_x, next_pos_y)

## calculate the distance between two points
#func distance_two_points(point1, point2):
#	var distance = (point1.x - point2.x)*(point1.x - point2.x) +\
#		(point1.y - point2.y)*(point1.y - point2.y)
#	distance = sqrt(distance)
#	return distance

func length_of_complex_value(complex):
	var length = sqrt(complex[0]*complex[0]+complex[1]*complex[1])
	return stepify(length,0.1)

# draw a tick
func draw_a_tick(location):
	draw_line(location, location+Vector2(-5,-5),ColorN("Black"),1.5,true)
	draw_line(location, location+Vector2(5.5,-11),ColorN("Black"),1.5,true)

#################################################################################

# animation frame index increment
func _on_Timer_draw_evolution_timeout():
	evolution_step += 1
	# keep the final graph for a while
	if evolution_step >= evolution_state_number+2 and first_wait:
		evolution_step = evolution_state_number+1
		wait_timer.set_wait_time(still_time)	
		wait_timer.start()  
		first_wait = false
	if evolution_step >= evolution_state_number+2:
		evolution_step = evolution_state_number+1

func _on_Timer2_wait_timeout():
	evolution_step = 0 # make the redrawing slower
	first_wait = true
	wait_timer.stop()
