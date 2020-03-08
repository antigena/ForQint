extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

onready var Text = get_node("Button/Text")
onready var Trigger = get_node("Button/Trigger")

var previous_pressing = false
var is_pressing = false
var ignore_input = true
export var my_action = "fire"

func to_letter(number):
	if(number == 0):
		return "a"
	if(number == 1):
		return "b"
	if(number == 2):
		return "c"
	if(number == 3):
		return "d"
	
func set_action(action):
	my_action = action
	set_trigger(to_letter(int(my_action)))

func set_label_text(text):
	Text.set_text(text)

func set_trigger(text):
	Trigger.set_text(text)

func get_button():
	return get_node("Button")

func _fixed_process(delta):
	if(!is_visible()):
		return
	var pressing = Input.is_action_pressed(my_action)
	if(pressing and not previous_pressing):
#		print(get_name() + ": my action is: " + my_action)
		get_node("Button").emit_signal("pressed")
	previous_pressing = pressing
	
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_fixed_process(true)
	set_process_input(true)

func _on_Continue_visibility_changed():
	previous_pressing = false
