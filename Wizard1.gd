
extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func set_frame(frame):
	for item in get_children():
		if(item.is_type("Sprite")):
			item.frame = frame
			return

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass 