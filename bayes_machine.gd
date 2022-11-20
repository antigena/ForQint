extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal evaluation_time_up
export var answer_time = 5

var machine = {
"0000": false,
"0001": false,
"0010": false,
"0011": true,
"0100": false,
"0101": true,
"0110": false,
"0111": true,
"1000": false,
"1001": false,
"1010": false,
"1011": false,
"1100": false,
"1101": true,
"1110": false,
"1111": true
}

var patients = {
  "Patients":
  [
    {"case": "#123", "id": "jdn232", "age": "58", "description": "Dizem os vizinhos que não conseguem dormir com o barulho que faz, especialmente desde que voltou de uma viagem misteriosa, de onde trouxe criaturas fantásticas\n", "pic": "", "key": "0011"},
    {"case": "#620", "id": "judm53", "age": "185", "description": "Chamam-lhe a corneta da noite. Corneta, porque com a temperatura que tem, não pode ser corneto. Não pode não\n", "pic": "", "key": "1011"},
    {"case": "#364", "id": "adg233", "age": "33", "description": "Tem em casa um lindo papagaio, que não se sabe de onde veio...\n", "pic": "", "key": "0100"},
    {"case": "#455", "id": "phn9k8", "age": "226", "description": "Foi viajar, e sente-se com imenso frio, apesar do calor que faz. A mulher dorme no quarto ao lado, com tampões nos ouvidos.\n\n", "pic": "", "key": "1111"},
  ]
}


onready var buttons = get_tree().get_nodes_in_group("machine_button")
onready var red_light = get_node("Painel/red_light_bulb")
onready var green_light = get_node("Painel/green_light_bulb")

var buttons_state = [0,0,0,0]
var current_patient = 0
var previous_pressed = false

var timer = null
var key_on_timer = ""
var can_press_keys = false

func set_allow_interaction(value):
	for bt in buttons:
		var btn = bt.get_node("button")
		btn.set_disabled(!value)
	can_press_keys = value
	previous_pressed = true
	
func reset():
	current_patient = -1

func show_next_patient():
	if(current_patient >= 0):
		get_node("Painel/papyrus/pictures/picture" + str(current_patient + 1)).hide()
	current_patient += 1
	show_patient(current_patient)
	get_node("Painel/papyrus/pictures/picture" + str(current_patient + 1)).show()
	timer.start()


func show_patient(patient):
	var patient_info = patients["Patients"][patient]
	reset_buttons()
	check_buttons()
	show_light()
	for item in patient_info.keys():
		if(has_node("Painel/papyrus/" + item)):
			get_node("Painel/papyrus/" + item).set_text(patient_info[item])

func is_current_patient_sick():
	return machine[get_current_patient_key()]

func get_current_patient_key():
	return patients["Patients"][current_patient]["key"]

func get_buttons_state():
	return key_on_timer

func show_red():
	green_light.hide()
	red_light.show()

func show_green():
	red_light.hide()
	green_light.show()

func generate_key():
	var key = ""
	for s in buttons_state:
		key += str(s)
	return key

func reset_buttons():
	for bt in buttons:
		var btn = bt.get_node("button")
		btn.set_pressed(false)
		
func check_buttons():
	for bt in buttons:
		var btn = bt.get_node("button")
		var btn_idx = int(bt.get_name()) - 1
		var toggled = btn.is_pressed()
		if(toggled):
			buttons_state[btn_idx] = 1
		else:
			buttons_state[btn_idx] = 0

func show_light():
	var key = generate_key()
	if(not machine[key]):
		show_green()
	else:
		show_red()

func _fixed_process(delta):
	process_input()
	show_light()
	get_node("Painel/clock/time_left").set_text(str(round(timer.get_time_left())))

func process_input():
	if(!can_press_keys):
		return
	
	var pressing = false
	var btn = -1
	if(Input.is_action_pressed("fire")):
		btn = 4
	elif(Input.is_action_pressed("opt_1")):
		btn = 1
	elif(Input.is_action_pressed("opt_2")):
		btn = 2
	elif(Input.is_action_pressed("opt_3")):
		btn = 3
	
	if(btn > 0):
		pressing = true
	if(pressing and not previous_pressed):
		var button = get_node("Painel/button_" + str(btn) + "/button")
		button.set_pressed(!button.is_pressed)
		button.emit_signal("toggled", button.is_pressed())
		
	previous_pressed = pressing
			
	
func _on_timer_timeout():
	timer.stop()
	key_on_timer = generate_key()
	emit_signal("evaluation_time_up")

func set_timer():
	timer = Timer.new()
	timer.connect("timeout", self, "_on_timer_timeout")
	timer.set_wait_time(answer_time)
	add_child(timer)



func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_fixed_process(true)
	set_process_input(true)
	set_timer()
	show_light()
	reset()
	
	show_patient(3)
	

#	show_next_patient()

func _on_button_toggled( pressed ):
	check_buttons()
