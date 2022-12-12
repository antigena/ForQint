extends Panel

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal menu_on

var previous_click = false
var showing_credits = false

func _on_end_titles_end():
	showing_credits = false

func connect_button_to(button, obj, function):
	if(has_node(button)):
		get_node(button).connect("pressed", obj, function)
	#	print("Connecting " + button + " to function " + function)

func set_end():
	get_node("Comecar").hide()
	get_node("Continuar").hide()
	get_node("Terminar").show()
	get_node("Credi