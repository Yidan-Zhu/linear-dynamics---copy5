extends Line2D

#####################
#       PARAMS
#####################
# eigens calculation
var transform_matrix = Transform2D()
var old_matrix = Transform2D()
onready var slider00 = get_node("../Line2D_evolution/Line2D_Slider/HSlider00")
onready var slider01 = get_node("../Line2D_evolution/Line2D_Slider/HSlider01")
onready var slider10 = get_node("../Line2D_evolution/Line2D_Slider/HSlider10")
onready var slider11 = get_node("../Line2D_evolution/Line2D_Slider/HSlider11")

var lambda01
var lambda02
var eigenvec01
var eigenvec02
var complex_mode = false  # general for eigens

# eigenval drawing
var eigenval_origin = Vector2(200,180)
var val_scale_width = 25.0*2   # x : 50 pixel = 1
var color_eigens1 = Color(115.0/255.0, 222.0/255.0, 216.0/255.0, 1.0)
var color_eigens2 = ColorN("Red")
var dot_pos_1
var dot_pos_2

# eigenvec drawing
var eigenvec_origin = Vector2(200,450)
var vec_scale_width = 100.0
var arrow_end_1
var arrow_end_2

# UI
var events = {}
var input_position
var touch_radius = 10
var reverse_flag = false  # reverse calculation from eigens
var real_imag_margin = 7

var val_right = eigenval_origin.x + 100
var val_left = eigenval_origin.x - 100
var val_top = eigenval_origin.y - 100
var val_bottom = eigenval_origin.y + 100

# reverse calculate the matrix
var middle_matx = Transform2D()
var P_matx = Transform2D()
var P_reverse = Transform2D()

var new_00
var new_01
var new_10
var new_11

#######################################################

func _ready():
	# get matrix and calculate the eigens
	transform_matrix.x.x = stepify(sinh(slider00.value),0.1)
	transform_matrix.x.y = stepify(sinh(slider01.value),0.1)
	transform_matrix.y.x = stepify(sinh(slider10.value),0.1)
	transform_matrix.y.y = stepify(sinh(slider11.value),0.1)
	old_matrix = transform_matrix

	var lambda = calculate_eigenvalues(transform_matrix)
	lambda01 = lambda[0]
	lambda02 = lambda[1]
	if typeof(lambda01) != 3:  # a complex number
		complex_mode = true
	else:
		complex_mode = false

	eigenvec01 = calculate_eigenvectors(transform_matrix,lambda01,complex_mode)
	eigenvec02 = calculate_eigenvectors(transform_matrix,lambda02,complex_mode)


func _process(delta):
	transform_matrix.x.x = stepify(sinh(slider00.value),0.1)
	transform_matrix.x.y = stepify(sinh(slider01.value),0.1)
	transform_matrix.y.x = stepify(sinh(slider10.value),0.1)
	transform_matrix.y.y = stepify(sinh(slider11.value),0.1)
	
	if old_matrix != transform_matrix:	
		reverse_flag = false
		old_matrix = transform_matrix  ## finger input will change the matrix

	if !reverse_flag:
		var lambda = calculate_eigenvalues(transform_matrix)
		lambda01 = lambda[0]
		lambda02 = lambda[1]
		if typeof(lambda01) != 3:  # a complex number
			complex_mode = true
		else:
			complex_mode = false

		eigenvec01 = calculate_eigenvectors(transform_matrix,lambda01, complex_mode)
		eigenvec02 = calculate_eigenvectors(transform_matrix,lambda02, complex_mode)
	else:
	#reversely recover the matrix	
		middle_matx.x.x = lambda01
		middle_matx.x.y = 0
		middle_matx.y.x = 0
		middle_matx.y.y = lambda02

		P_matx.x.x = eigenvec01[0]
		P_matx.y.x = eigenvec01[1]
		P_matx.x.y = eigenvec02[0]
		P_matx.y.y = eigenvec02[1]

		# reverse of a rotation matrix is the transpose
		P_reverse.x.x = eigenvec01[0]
		P_reverse.y.x = eigenvec02[0]
		P_reverse.x.y = eigenvec01[1]
		P_reverse.y.y = eigenvec02[1]

		var matrix = P_matx*middle_matx*P_reverse
		#print([matrix.x.x - transform_matrix.x.x,matrix.x.y - transform_matrix.x.y,\
		#	matrix.y.x - transform_matrix.y.x,matrix.y.y - transform_matrix.y.y])
#		# change the slider values

		new_00 = stepify(sinh_reverse(matrix.x.x),0.01)
		new_01 = stepify(sinh_reverse(matrix.x.y),0.01)
		new_10 = stepify(sinh_reverse(matrix.y.x),0.01)
		new_11 = stepify(sinh_reverse(matrix.y.y),0.01)
		#print([new_00,new_01,new_10,new_11])
#		if new_00 > slider00.max_value:
#			slider00.value = slider00.max_value
#		elif new_00 < slider00.min_value:
#			slider00.value = slider00.min_value
#		else:
#			slider00.value = new_00
#
#		if new_01 > slider01.max_value:
#			slider01.value = slider01.max_value
#		elif new_01 < slider01.min_value:
#			slider01.value = slider01.min_value
#		else:
#			slider01.value = new_01		
#
#		if new_10 > slider10.max_value:
#			slider10.value = slider10.max_value
#		elif new_10 < slider10.min_value:
#			slider10.value = slider10.min_value
#		else:
#			slider10.value = new_10			
#
#		if new_11 > slider11.max_value:
#			slider11.value = slider11.max_value
#		elif new_11 < slider11.min_value:
#			slider11.value = slider11.min_value
#		else:
#			slider11.value = new_11
#
		reverse_flag = false
			
	update()


#####################################################

func _input(event):			
	if event is InputEventScreenDrag:
		events[event.index] = event
		# one-finger drag
		if events.size() == 1:
			input_position = events[0].position
			# change the eigenvals
			if input_position.x < val_right and input_position.x > val_left\
				and input_position.y < val_bottom and input_position.y > val_top:
				var dis1 = distance_two_points(dot_pos_1, input_position)
				var dis2 = distance_two_points(dot_pos_2, input_position)
				# move the nearest dot, within a radius
				if dis1 < touch_radius and dis2 > touch_radius:
					dot_pos_1.x = input_position.x
					if abs((dot_pos_1-eigenval_origin).y) >= real_imag_margin: # complex value
#						dot_pos_2.x = dot_pos_1.x
#						dot_pos_2.y = (2.0*eigenval_origin-dot_pos_1).y
#						complex_mode = true
						pass
					else:  # real
						dot_pos_1.y = eigenval_origin.y
						dot_pos_2.y = eigenval_origin.y
						complex_mode = false
					reverse_flag = true
					#################################
					#   calculate new eigens
					#################################
					if complex_mode:
#						lambda01 = [(dot_pos_1-eigenval_origin).x/val_scale_width,
#							(eigenval_origin-dot_pos_1).y/val_scale_width]
#						lambda02 = [lambda01[0],-lambda01[1]]
						pass
						# two new complex eigenvecs from eigenvec1, push back 0.2
					
					else:
						lambda01 = (dot_pos_1-eigenval_origin).x/val_scale_width
						lambda02 = (dot_pos_2-eigenval_origin).x/val_scale_width
						# the eigenvecs can keep the previous value...??
						update()
				elif dis2 < touch_radius and dis1 > touch_radius:
					dot_pos_2.x = input_position.x
					if abs((dot_pos_2-eigenval_origin).y) >= real_imag_margin: # complex value
#						dot_pos_1.x = dot_pos_2.x
#						dot_pos_1.y = (2.0*eigenval_origin-dot_pos_2).y
#						complex_mode = true
						pass
					else:
						dot_pos_1.y = eigenval_origin.y
						dot_pos_2.y = eigenval_origin.y
						complex_mode = false
						update()
					reverse_flag = true
					
				elif dis1 < touch_radius and dis2 < touch_radius: 
					# both on the x axis can be that close, real values
					dot_pos_1.x = input_position.x
					dot_pos_1.y = eigenval_origin.y
					dot_pos_2.y = eigenval_origin.y
					complex_mode = false
					reverse_flag = true
					update()

			# change the eigenvecs
			if distance_two_points(eigenvec_origin, input_position) \
				<= 100+2.0*real_imag_margin:
				# real vector	
				if distance_two_points(eigenvec_origin, input_position) \
					>= 100 - 2.0*real_imag_margin: 
					complex_mode = false
					if (distance_two_points(arrow_end_1, input_position) < 2.0*touch_radius\
						and distance_two_points(arrow_end_2, input_position)> 2.0*touch_radius)\
					   or (distance_two_points(arrow_end_2, input_position) < 2.0*touch_radius\
						and distance_two_points(arrow_end_1, input_position) < 2.0*touch_radius):
						arrow_end_1 = 100*(input_position-eigenvec_origin).normalized()
						arrow_end_1 += eigenvec_origin
						arrow_end_2 = 100*(arrow_end_2-eigenvec_origin).normalized()
						arrow_end_2 += eigenvec_origin						
						reverse_flag = true
						update()
					elif distance_two_points(arrow_end_2, input_position) < 2.0*touch_radius\
						and distance_two_points(arrow_end_1, input_position)> 2.0*touch_radius:
						arrow_end_2 = 100*(input_position-eigenvec_origin).normalized()
						arrow_end_2 += eigenvec_origin
						arrow_end_1 = 100*(arrow_end_1-eigenvec_origin).normalized()
						arrow_end_1 += eigenvec_origin
						reverse_flag = true
						update()					
				
				# imaginary eigenvector
				else:
					pass
#					complex_mode = true
#					reverse_flag = true
#					if (distance_two_points(arrow_end_1, input_position) < 2.0*touch_radius\
#						and distance_two_points(arrow_end_2, input_position)> 2.0*touch_radius)\
#					   or (distance_two_points(arrow_end_2, input_position) < 2.0*touch_radius\
#						and distance_two_points(arrow_end_1, input_position) < 2.0*touch_radius)\
#					   or (distance_two_points(arrow_end_2, input_position) < 2.0*touch_radius\
#						and distance_two_points(arrow_end_1, input_position)> 2.0*touch_radius):
#						arrow_end_1 = input_position
#						arrow_end_2 = input_position
#						var up = (arrow_end_1.x-eigenvec_origin.x)/vec_scale_width
#						var down = (eigenvec_origin.y-arrow_end_1.y)/vec_scale_width
#						eigenvec01 = [up,[down,reverse_calculate_imaginary_vec(up,down)]]
#						eigenvec02 = [up,[down,-reverse_calculate_imaginary_vec(up,down)]]
#						update()
				
func _draw():
	# draw the eigenvals dots
	if complex_mode == false:
		if !reverse_flag: 
			# not reverse calculation, update from lambda values
			dot_pos_1 = Vector2(lambda01*val_scale_width,0)+eigenval_origin
			dot_pos_2 = Vector2(lambda02*val_scale_width,0)+eigenval_origin
		draw_circle(dot_pos_1,4.0, color_eigens1)
		draw_circle(dot_pos_2,4.0, color_eigens2)			
	elif complex_mode:
		if !reverse_flag:
			dot_pos_1 = Vector2(lambda01[0]*val_scale_width,\
				lambda01[1]*val_scale_width)+eigenval_origin
			dot_pos_2 = Vector2(lambda02[0]*val_scale_width,\
				lambda02[1]*val_scale_width)+eigenval_origin
		draw_circle(dot_pos_1,4.0,color_eigens1)
		draw_circle(dot_pos_2,4.0,color_eigens2)

	# draw te eigenvecs arrows
	if complex_mode == false:
		if get_node_or_null("Label_complex"):
			get_node("Label_complex").queue_free()
		if !reverse_flag:	
			arrow_end_1 = eigenvec_origin+vec_scale_width*\
				Vector2(eigenvec01[0],eigenvec01[1])
			arrow_end_2 = eigenvec_origin+vec_scale_width*\
				Vector2(eigenvec02[0],eigenvec02[1])
		draw_line(eigenvec_origin, arrow_end_1,color_eigens1,2.0,true)
		draw_small_arrow(arrow_end_1, arrow_end_1-eigenvec_origin, \
			color_eigens1)
		draw_line(eigenvec_origin, arrow_end_2,color_eigens2,2.0,true)
		draw_small_arrow(arrow_end_2, arrow_end_2-eigenvec_origin, \
			color_eigens2)	
	else:
		if !reverse_flag:
			arrow_end_1 = eigenvec_origin+vec_scale_width*\
				Vector2(eigenvec01[0],eigenvec01[1][0])  # the real part
			arrow_end_2 = eigenvec_origin+vec_scale_width*\
				Vector2(eigenvec02[0],eigenvec02[1][0])  # the real part
		draw_line(eigenvec_origin, arrow_end_1,color_eigens1,2.0,true)
		draw_small_arrow(arrow_end_1, arrow_end_1-eigenvec_origin, \
			color_eigens1)				
		draw_line(eigenvec_origin, arrow_end_2,color_eigens2,2.0,true)
		draw_small_arrow(arrow_end_2, arrow_end_2-eigenvec_origin, \
			color_eigens2)	
			
		var dynamic_font = DynamicFont.new()
		dynamic_font.font_data = load("res://Fonts/BebasNeue_Bold.ttf")
		dynamic_font.size = 18
		
		if !get_node_or_null("Label_complex"):
			var node = Label.new()
			node.name = "Label_complex"
			add_child(node)	
		get_node("Label_complex").set_global_position(\
			eigenvec_origin + Vector2(-150,-130))
		get_node("Label_complex").text = "Eigenvectors:\n[ "+str(eigenvec02[0])+\
			", "+str(eigenvec02[1][0])+"±("+str(eigenvec02[1][1])+")j ]"
		get_node("Label_complex").add_font_override("font",dynamic_font)			
		get_node("Label_complex").add_color_override("font_color", color_eigens1)

###################################################
# Calculate eigens from matrix
func calculate_eigenvalues(matrix):
	var delta_eqn = (matrix.x.x+matrix.y.y)*(matrix.x.x+matrix.y.y)-\
		4*(matrix.x.x*matrix.y.y-matrix.x.y*matrix.y.x)
	var lambda_1
	var lambda_2
	if delta_eqn >= 0:
		lambda_1 = (matrix.x.x+matrix.y.y)/2.0+sqrt(delta_eqn)/2.0
		lambda_2 = (matrix.x.x+matrix.y.y)/2.0-sqrt(delta_eqn)/2.0
		lambda_1 = stepify(lambda_1,0.1)
		lambda_2 = stepify(lambda_2,0.1)
	else:
		lambda_1 = [(matrix.x.x+matrix.y.y)/2.0, sqrt(-delta_eqn)/2.0]
		lambda_2 = [(matrix.x.x+matrix.y.y)/2.0, -sqrt(-delta_eqn)/2.0]		
		lambda_1[0] = stepify(lambda_1[0],0.1)
		lambda_1[1] = stepify(lambda_1[1],0.1)		
		lambda_2[0] = stepify(lambda_2[0],0.1)
		lambda_2[1] = stepify(lambda_2[1],0.1)	
		if lambda_1[1] == 0: # very small imaginary number
			lambda_1 = lambda_1[0] 
			lambda_2 = lambda_2[0]
						 
	return [lambda_1, lambda_2]

func calculate_eigenvectors(matrix, eigenvalue, mode):
	var eigenvector_upper = 1
	var eigenvector_down = 1
	if mode == false:  # not a complex lambda
		eigenvector_upper = matrix.x.y
		eigenvector_down = eigenvalue - matrix.x.x
		if !(eigenvector_upper==0 and eigenvector_down==0):
			var denominator = sqrt(eigenvector_upper*eigenvector_upper+\
				eigenvector_down*eigenvector_down)
			eigenvector_upper = stepify(eigenvector_upper/denominator,0.01)
			eigenvector_down = stepify(eigenvector_down/denominator,0.01)
	else: # a complex lambda		
		eigenvector_upper = matrix.x.y
		eigenvector_down = [eigenvalue[0] - matrix.x.x, eigenvalue[1]]

	return [eigenvector_upper, eigenvector_down]
	
# draw a small arrow
func draw_small_arrow(location, direction, color):
	direction = direction.normalized()
	var b = location + direction.rotated(PI*4.0/5.0)*10
	draw_line(b, location, color, 1.5, true)
	var c = location + direction.rotated(-PI*4.0/5.0)*10
	draw_line(c, location, color, 1.5, true)

# calculate the distance between two points
func distance_two_points(point1, point2):
	var distance = (point1.x - point2.x)*(point1.x - point2.x) +\
		(point1.y - point2.y)*(point1.y - point2.y)
	distance = sqrt(distance)
	return distance

# calculate the imaginary part of eigenvec
func reverse_calculate_imaginary_vec(upper, down_real):
	var img = sqrt(1 - upper*upper - down_real*down_real)
	img = stepify(img, 0.1)
	return img
	
func sinh_reverse(x):
	return 1.0/sinh(x)
