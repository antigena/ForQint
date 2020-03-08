
extends TextureFrame

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

onready var ContinueButton = get_node("Continue")
onready var ButtonContainer = get_node("Buttons")

var ButtonTemplate = preload("res://AnswerButton.tscn")

func clear_buttons():
	var current_buttons = ButtonContainer.get_children()
	for item in current_buttons:
		item.queue_free()

func hide_interaction_text():
	get_node("Text").hide()
	get_node("Continue").hide()
	get_node("Buttons").show()

func show_interaction_text():
	get_node("Buttons").hide()
	clear_buttons()
	
	get_node("Text").show()
	get_node("Continue").show()

func show_wizard(wizard):
	hide_wizards()
	get_node("Frame/" + wizard).show()
	
func show_player():
	hide_wizards()
	get_node("Frame/Player").show()

func set_button_label_text(button, text):
	if (has_node("Buttons/button_" + str(button))):
		get_node("Buttons/button_" + str(button)).set_label_text(text)

func set_button_trigger(button, text):
	if (has_node("Buttons/button_" + str(button))):
		get_node("Buttons/button_" + str(button)).set_trigger(text)
	
func set_interaction_text(text):
	get_node("Text").set_text(text)
	
func connect_button(button, object, method):
	if(has_node("Buttons/button_" + str(button))):
		var btn = get_node("Buttons/button_" + str(button))
		btn.get_button().connect("pressed", object, method, [btn])

func set_n_buttons(buttons):	
	var dimensions_set = false
	var increment = 0
	var padding = 0
	var container_size = ButtonContainer.get_size()
	var height = 0
		
	for i in range(buttons):
		var button = ButtonTemplate.instance();
		ButtonContainer.add_child(button)
		if (!dimensions_set):			
			var button_size = button.get_size()
			increment = container_size.x / button_size.x
			padding = container_size.x - (buttons * button_size.x)
			if (padding > 0):
				padding = padding / buttons
			else:
				padding = 0
			increment = container_size.x / increment
			height = container_size.y * 0.5 - button_size.y * 0.5
			
			dimensions_set = true
		var button_pos = button.get_pos()
		button.set_name("button_" + str(i))
		button.set_action("opt_" + str(i + 1))
		button.set_pos(Vector2(padding + increment * i, height))
		


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	
	
	ContinueButton.set_label_text("Continuar")
	ContinueButton.set_action("fire")
	#ContinueButton.set_trigger("IV")
	
	"""	
	set_n_buttons(3)
	set_button_label_text(0, "Sim")
	set_button_label_text(1, "Não")
	set_button_label_text(2, "Talvez")
	
	set_button_trigger(0, "X")
	set_button_trigger(1, "Y")
	set_button_trigger(2, "Z")
	"""

func hide_wizards():
	var wizards = get_node("Frame").get_children()
	for item in wizards:
		item.hide()
	
func _on_Dialog_hide():
	hide_wizards()	