extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

const IDLE = "idle"
const WALK = "walk"

const DOWN = "down"
const UP = "up"
const LEFT = "left"
const RIGHT = "right"

const DIRECTIONS = [DOWN, UP, LEFT, RIGHT]

var state = IDLE
var direction = DOWN

onready var animation_engine = get_node("Avatar/Movement")
var player_in_sight = false
var destroyed = false

var delta_acc = 0

export var can_attack = true
export var attack_range = 4
export var available_fire_balls = 3

var player = null

const TILE_SIZE = 16

var previous_shot = false

var fire_ball_count = available_fire_balls


func fire_ball_destroyed():
	fire_ball_count += 1
	if (fire_ball_count > available_fire_balls):
		fire_ball_count = available_fire_balls
	
func fire_fire_ball(direction):
	fire_ball_count -= 1
	var shot = preload("res://fire_ball.tscn").instance()
	shot.set_pos(get_global_pos())
	shot.set_owner(self)
	shot.set_direction(direction)
	shot.connect("shot_destroyed", self, "fire_ball_destroyed", [], CONNECT_ONESHOT)
	player.get_node("../..").add_child(shot)
	#print("firing from " + str(get_global_pos()) + " in the direction " + str(direction))
	
func process_movement(delta):
	state = IDLE
	if(player_in_sight):
		state = WALK
		#check player's direction
	else:
		if(rand_range(0, 1.0) > 0.5):
			delta_acc += delta
		if(delta_acc > 1):
			direction = DIRECTIONS[round(rand_range(0, 3))]
			delta_acc = 0
			previous_shot = false
	
	var animation = state + "_" + direction
	animation_engine.play(animation)
	
func process_attack(delta):
	var player_pos = player.get_pos()
	var distance = (get_pos() - player_pos).length()
	
	var shooting = false
	if((distance / TILE_SIZE) <= attack_range):
		var normalized_direction = (get_pos() - player_pos).normalized()
		var player_direction = UP
		
		if(abs(normalized_direction.x) > abs(normalized_direction.y)):
			if(normalized_direction.x >= 0):
				player_direction = LEFT
			else:
				player_direction = RIGHT
		else:
			if(normalized_direction.y >= 0):
				player_direction = UP
			else:
				player_direction = DOWN
				
		shooting = true
		if(direction == player_direction):
			if(fire_ball_count > 0):
				if(shooting and not previous_shot):
					fire_fire_ball(-normalized_direction)
					
	previous_shot = shooting

func destroy():
	if(destroyed):
		return
	destroyed = true
	set_fixed_process(false)
	animation_engine.play("destroy")

func _fixed_process(delta):
	process_movement(delta)
	if(can_attack):
		process_attack(delta)
		
func _on_body_enter(body):
	if(body == player):
		player.player_hit()

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	randomize()
	
	var node = get_parent()
	while(!node.has_node("Player")):
		node = node.get_parent()
	player = node.get_node("Player")
	
	self.connect("body_enter", self, "_on_body_enter")
	set_fixed_process(true)
