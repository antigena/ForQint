
extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

onready var map_floor = get_node("floor")
onready var Player = get_node("Player")
onready var DialogParser = get_node("DialogParser")

onready var Menu = get_node("Menu").get_node("Menu")

func _on_Collider_body_enter(body, caller):
	if(body != Player):
		return
#	if(KeeperCount != 0):
#		return
		
	DialogParser.start_interaction(caller.get_name())
	#Player.start_interaction(caller.get_name())

func add_reward():
	get_node("Blockage").queue_free()
	
func pause(value):
	get_tree().set_pause(value)
	
func _on_button_comecar():
	Menu.hide()
	pause(false)

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
#	print(map_floor.get_used_rect())
	Player.set_world_size(Vector2(-16, 16), Vector2(28, -5))
	Player.restore_life()
	
	var Interactive = get_tree().get_nodes_in_group("interactive")
	for i in range(Interactive.size()):
		var node = get_node(Interactive[i].get_path())
		var args = Array([node])
		node.connect("body_enter", self, "_on_Collider_body_enter", args)
	
	DialogParser.load_scene("beginning")
	Menu.connect_button_to("Comecar", self, "_on_button_comecar")
	Menu.connect_button_to("Continuar", self, "_on_button_continuar")
	Menu.connect_button_to("Terminar", self, "_on_button_terminar")

	Menu.connect("menu_on", self, "_on_menu")
	Menu.set_beginning()
	
	Menu.show()
	pause(true)
		

func _on_NextLevel_body_enter( body ):
	if(body == Player):
		get_tree().change_scene("res://3doors.tscn")