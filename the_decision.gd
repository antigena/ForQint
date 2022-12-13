
extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

onready var Player = get_node("Player")
onready var DialogParser = get_node("DialogParser")
onready var TheMachine = get_node("HUD/TheMachine")

var delta_accum = 0

var KeeperCount = 0

onready var Menu = get_node("Menu").get_node("Menu")

func add_reward():
#	get_node("HUD/Coin/Part_1").show()
	TheMachine.hide()
	Player.highlight_coin(3)
		
func random_light():
	if (delta_accum < 2.5):
		return
	var light = round(rand_range(0, 1))
	if (light == 0):
		get_node("light_bulbs/red").show()
		get_node("light_bulbs/green").hide()
	else:	
		get_node("light_bulbs/red").hide()
		get_node("light_bulbs/green").show()
	delta_accum = 0

func _fixed_process(delta):
	delta_accum += delta
	
	random_light()
	

func _on_Collider_body_enter(body, caller):
	if(body != Player):
		return
#	if(KeeperCount != 0):
#		return
		
	DialogParser.start_interaction(caller.get_name())
	#Player.start_interaction(caller.get_name(

func start():
	get_node("light_bulbs/red").hide()
	get_node("light_bulbs/green").show()

func _on_evaluation_time_up():
	DialogParser.StateVariables["patient_key"] = TheMachine.get_current_patient_key()
	DialogParser.StateVariables["key_combination"] = TheMachine.get_buttons_state()
	DialogParser.StateVariables["patient_health"] = str(TheMachine.is_current_patient_sick()).to_lower()
	
	TheMachine.set_allow_interaction(false)
	DialogParser.continue_the_execution()	
	
func show_next_patient():
	TheMachine.set_allow_interaction(true)
	if(!TheMachine.is_visible()):
		TheMachine.show()
	TheMachine.connect("evaluation_time_up", self, "_on_evaluation_time_up", [], CONNECT_ONESHOT)
	TheMachine.show_next_patient()
		
func pause(value):
	get_tree().set_pause(value)
	
func _on_button_continuar():
	Menu.hide()
	pause(false)
	
func _on_button_terminar():
	get_tree().change_scene("res://main.tscn")
	
func _on_menu():
	Menu.set_middle()
	pause(true)
		
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	
	Player.set_world_size(Vector2(-7, 18), Vector2(18, -4))
	Player.restore_life()
	
	var Interactive = get_tree().get_nodes_in_group("interactive")
	for i in range(Interactive.size()):
		var node = get_node(Interactive[i].get_path())
		var args = Array([node])
		node.connect("body_enter", self, "_on_Collider_body_enter", args)
	
	var Keepers = get_tree().get_nodes_in_group("keeper")
	for i in range(Keepers.size()):
		var node = get_node(Keepers[i].get_path())
		KeeperCount += 1
		print("setting: " + node.get_path())
		node.connect("exit_tree", self, "_on_Keeper_exit_tree", [])
		
		
	for item in get_node("PatientsLeft").get_children():
		item.set_frame(3)

	for item in get_node("PatientsUp").get_children():
		item.set_frame(1)
	
	DialogParser.load_scene("drbayer")	

	Menu.connect_button_to("Comecar", self, "_on_button_comecar")
	Menu.connect_button_to("Continuar", self, "_on_button_continuar")
	Menu.connect_button_to("Terminar", self, "_on_button_terminar")

	Menu.connect("menu_on", self, "_on_menu")
	Menu.hide()
	Menu.set_middle()
	
	Player.highlight_coin(1)
	Player.highlight_coin(2)
	Player.spawn()

	randomize()
	set_fixed_process(true)


func _on_Area2D_body_enter( body ):
	if(body == Player and DialogParser.StateVariables["end_quest"]):
#	if(body == Player):
		get_tree().change_scene("res://final.tscn")