extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal stop_spinning

onready var spinning_wheel = get_node("Wheel")
onready var pin = get_node("Pin")

var rotation = 0
var rotation_speed = 5.0

var pin_rotation_speed = 10.0
var pin_rotation = 0
var rotating = true

var accum_delta = 0
var key_position = 0
var initial_rotation = 0

func random_key_position():
	randomize()
	key_position = round(rand_range(0, 5))
	print("key position: " + str(key_position))

func show_item(item):
	if (item == key_position or item == (int(key_position + 1)) % 6):
		spinning_wheel.get_node("gold_key_" + str(item)).show()
	else:
		spinning_wheel.get_node("gold_coin_" + str(item)).show()

func random_initial_rotation(key):
	spinning_wheel.set_rot(0)
	randomize()
	
	initial_rotation = round(rand_range(0, 5))
	
	if(key):
		while(initial_rotation == key_position or initial_rotation == int(key_position + 1) % 6):
			initial_rotation = round(rand_range(0, 5))
	
	spinning_wheel.rotate(deg2rad(initial_rotation * 60))
	print("initial: " + str(initial_rotation))

func rotate():
	rotation += rotation_speed 
	pin_rotation += pin_rotation_speed
	 
	if(rotation > 360):
		rotation = 0
	spinning_wheel.rotate(deg2rad(rotation_speed))
	if(pin_rotation > 5 or pin_rotation < -5):
		pin_rotation_speed = -pin_rotation_speed
	pin.rotate(deg2rad(pin_rotation_speed))
	
func _fixed_process(delta):
	if(rotating):
		rotate()
		
		accum_delta += delta
		
		if (accum_delta > 1):
			accum_delta = 0
			pin_rotation_speed *= 0.8
			rotation_speed *= 0.8
			
		if(rotation_speed <= 0.12):
			print("stop spinning")
			rotating = false
			show_item(initial_rotation)
			emit_signal("stop_spinning")
	"""
	else:
		if(Input.is_action_pressed("fire")):
			reset(false)
		if(Input.is_action_pressed("move_right")):
			show_item((int(initial_rotation + 1) % 6))
	"""
	
func hide_all():
	var items = get_tree().get_nodes_in_group("wheel_item")
	for item in items:
		item.hide()

func reset(key):
	rotation = 0
	rotation_speed = 5.0

	pin_rotation_speed = 10.0
	pin_rotation = 0
	rotating = true

	accum_delta = 0
	
	hide_all()
	if(key):
		random_key_position()
	random_initial_rotation(key)
	
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_fixed_process(true)
#	set_process_input(true)
	
	hide_all()
	rotating = false
	
#	reset(true)
	


