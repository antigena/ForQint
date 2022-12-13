
extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var state = "idle"
var direction = "right"

var canInteract = false
var canWalk = true

var current_animation = state + "_" + direction
var previous_animation = ""
var speed = 10

var previous_shooting = false

const MAX_NUMBER_SHURIKENS = 5
var number_shurikens_available = MAX_NUMBER_SHURIKENS

const TILE_SIZE = 16

onready var animation_engine = get_node("Player/Movement")
onready var shooting_position = get_node("ShootFrom")

var current_wizard = null

export var total_life = 5
var life = total_life

func highlight_coin(part):
	get_node("Hud/Coin/Part_" + str(part)).show()

func spawn():
	set_pos(get_node("../Spawn").get_pos())
	
func restore_life():
	life = total_life

func player_hit():
	life -= 1
	if (life == 0):
		spawn()
		life = 5

func set_world_size(width, height):
	get_node("Camera2D").set_limit(MARGIN_LEFT, width.x * TILE_SIZE * 2)
	get_node("Camera2D").set_limit(MARGIN_TOP, height.y * TILE_SIZE * 2)
	get_node("Camera2D").set_limit(MARGIN_RIGHT, width.y * TILE_SIZE * 2)
	get_node("Camera2D").set_limit(MARGIN_BOTTOM, height.x * TILE_SIZE * 2)

func process_movement(delta):
	if(not canWalk):
		return
	
	var motion = Vector2(0, 0)
	
	state = "idle"
	if(Input.is_action_pressed("move_left")):
		state = "walk"
		direction = "left"
		motion += Vector2(-1, 0)
	if(Input.is_action_pressed("move_right")):
		state = "walk"
		direction = "right"
		motion += Vector2(1, 0)
	if(Input.is_action_pressed("move_up")):
		state = "walk"
		direction = "up"
		motion += Vector2(0, -1)
	if(Input.is_action_pressed("move_down")):
		state = "walk"
		direction = "down"
		motion += Vector2(0, 1)
		
	var shooting = false
	if(Input.is_action_pressed("fire") && number_shurikens_available > 0):
		shooting = true

#	if(is_colliding()):
#		print("I'm hit!")
	
	motion = motion.normalized()

	if(shooting and not previous_shooting):
		var shot = preload("res://shuriken.tscn").instance()
		shot.set_pos(shooting_position.get_global_pos())
		shot.set_owner(self)
		shot.set_friendly(true)
		shot.connect("shot_destroyed", self, "shuriken_destroyed", [], CONNECT_ONESHOT)
		
		var dir = motion.normalized()
		if (dir.length() == 0):
			if (direction == "down"):
				dir = Vector2(0, 1)
			elif (direction == "up"):
				dir = Vector2(0, -1)
			elif (direction == "left"):
				dir = Vector2(-1, 0)
			else: 
				dir = Vector2(1, 0)
		
		shot.set_direction(dir)
		get_node("../..").add_child(shot)
		number_shurikens_available -= 1

	previous_shooting = shooting

	motion = motion * speed * 0.5 * TILE_SIZE * delta
	move(motion)
	
	current_animation = state + "_" + direction
	if (current_animation != previous_animation):
		animation_engine.play(current_animation)
		previous_animation = current_animation
	
func refresh_ui(delta):
	for i in range(number_shurikens_available):
		get_node("Hud/Shurikens/Shuri_" + str(i)).show()
	for i in range(number_shurikens_available, MAX_NUMBER_SHURIKENS):
		get_node("Hud/Shurikens/Shuri_" + str(i)).hide()
		
	for i in range(life):
		get_node("Hud/Score/Heart_" + str(i)).set_frame(0)
	for i in range(life, total_life):
		get_node("Hud/Score/Heart_" + str(i)).set_frame(4)
		

func _fixed_process(delta):
	process_movement(delta)
	refresh_ui(delta)
	
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here

#	set_process_input(true)
	set_fixed_process(true)
	
func set_interacting(value):
	if (value):
		canInteract = true
		canWalk = false
		state = "idle"
		animation_engine.play(state + "_" + direction)
	else:
		canInteract = false
		canWalk = true
	
func is_interacting():
	return canInteract

func shuriken_destroyed():
	if (number_shurikens_available < MAX_NUMBER_SHURIKENS):
		number_shurikens_available += 1