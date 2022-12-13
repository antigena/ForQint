
extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var Direction = Vector2(0,0)
var Playing = false
var Speed = 20
var isFriendly = false

var owner = null

const TILE_SIZE = 16

var hit = false

onready var animation_engine = get_node("Anim")

signal shot_destroyed

func set_friendly(value):
	isFriendly = value

func get_direction():
	return Direction
	
func set_direction(dir):
	Direction = dir

func set_owner(owner):
	self.owner = owner
	
func alert_owner():
	emit_signal("shot_destroyed")
#	if (owner != null):
#		owner.fire_ball_destroyed()

func _hit_something():
	if(hit):
		return
	hit = true
	set_process(false)
	_on_VisibilityNotifier2D_exit_screen()
	
func _fixed_process(delta):
	if(not Playing):
		animation_engine.play("rotation");
		Playing = true
	
	var movement = Direction * Speed * 0.5 * TILE_SIZE * delta
	translate(movement)
	
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_fixed_process(true)

func _on_VisibilityNotifier2D_exit_screen():
	alert_owner()
	queue_free()

func _on_Shoot_area_enter( area ):
	if(area.is_in_group("transparent")):
		return
	if(isFriendly):
		if(area.has_method("destroy")):
			area.destroy()
	else:
		return
	_hit_something()

func _on_Shoot_body_enter( body ):
	var wr = weakref(owner)
	if(!wr.get_ref()):
		queue_free()
		return
	if (body.get_name() == owner.get_name()):
		return
	if(body.is_in_group("transparent")):
		return
	if(not isFriendly):
		if(body.has_method("player_hit")):
			body.player_hit()
	_hit_something()