
extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var tapped = false

func _draw():
	var r = Rect2(Vector2(), get_size())
	if(tapped):
		draw_rect(r, Color(1, 0, 0))
	else:
		draw_rect(r, Color(0, 0, 1))
		
func _input_event(event):
	if(event.type == InputEvent.MOUSE_BUTTON and event.pressed):
		tapped = true
		update()

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass