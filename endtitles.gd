extends Panel

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

onready var button = get_node("Continue")

signal end_titles_end

func _on_button_pressed():
	hide()
	emit_signal("end_titles_end")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	button.set_label_text("Continuar")
	button.set_action("fire")
	button.get_button().connect("pressed", self, "_on_button_pressed")
	
	pass
