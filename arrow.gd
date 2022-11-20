extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func _on_Arrow_visibility_changed():
	if(self.is_visible()):
		get_node("AnimationPlayer").play("up_and_down")
	else:
		get_node("AnimationPlayer").stop(true)