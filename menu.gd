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
	get_node("Creditos").show()

func set_middle():
	get_node("Comecar").hide()
	get_node("Continuar").show()
	get_node("Terminar").show()
	get_node("Creditos").show()

func set_beginning():
	get_node("Comecar").show()
	get_node("Continuar").hide()
	get_node("Terminar").hide()
	get_node("Creditos").show()
		

func _fixed_process(delta):
	
	var visible = is_visible()
	var clicking = false
	
	if(showing_credits):
		return
	
	if(Input.is_action_pressed("pause") and not visible):
		clicking = true
		emit_signal("menu_on")
		show()
	elif(visible):
		if(Input.is_action_pressed("fire") and get_node("Comecar").is_visible()):
			clicking = true
			if(clicking and not previous_click):
				get_node("Comecar").emit_signal("pressed")
		elif(Input.is_action_pressed("opt_1") and get_node("Continuar").is_visible()):
			clicking = true
			if(clicking and not previous_click):
				get_node("Continuar").emit_signal("pressed")
		elif(Input.is_action_pressed("opt_2") and get_node("Terminar").is_visible()):
			clicking = true
			if(clicking and not previous_click):
				get_node("Terminar").emit_signal("pressed")
		elif(Input.is_action_pressed("opt_3") and get_node("Creditos").is_visible()):
			clicking = true
			if(clicking and not previous_click):
				showing_credits = true
				show_credits()
	
	previous_click = clicking
		
func show_credits():
	get_node("../EndTitles/Panel").show()
	
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	
	get_node("../EndTitles/Panel").connect("end_titles_end", self, "_on_end_titles_end")
	set_fixed_process(true)
	set_process_input(true)
	
	