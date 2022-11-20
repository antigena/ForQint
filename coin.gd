extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal end_spin

onready var animation_player = get_node("animation")
onready var coin = get_node("Sprite")
var side_to_show = 0


func set_head_or_tails(head_or_tails):
	if(head_or_tails == 0):
		coin.frame = 8
	else:
		coin.frame = 0

func _on_animation_end():
	set_head_or_tails(side_to_show)
	emit_signal("end_spin")

func spin(amount, head_or_tails):
	side_to_show = head_or_tails
	animation_player.play("rotation")
	for i in range(amount):
		animation_player.queue("rotation")
	animation_player.connect("finished", self, "_on_animation_end", [], CONNECT_ONESHOT)

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	coin.frame = 0
