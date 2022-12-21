
extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal continue_execution

var KeeperCount = 0

var KeeperPositions = []

onready var Menu = get_node("Menu").get_node("Menu")

onready var Player = get_node("Player")
onready var DialogParser = get_node("DialogParser")
onready var spinning_wheel = get_node("HUD/spinning_wheel")

var KeeperTemplate = preload("res://enemy_2.tscn")

func _on_Collider_body_enter(body, caller):
	if(body != Player):
		return
	
	if(KeeperCount > 1):
		return
	
	DialogParser.start_interaction(caller.get_name())
	
func show_wheel():
	spinning_wheel.hide_all()
	spinning_wheel.show()
	
func hide_wheel():
	spinning_wheel.hide()

func _on_stop_spinning():
	DialogParser.continue_the_execution()
		
func spin(with_key):
	spinning_wheel.connect("stop_spinning", self, "_on_stop_spinning", [], CONNECT_DEFERRED | CONNECT_ONESHOT)
	spinning_wheel.reset(with_key)
	
func show_slice(slice):
	spinning_wheel.show_item(slice)
		
func get_key():
	return spinning_wheel.key_position
	
func get_slice():
	return spinning_wheel.initial_rotation

func set_slice(slice):
	spinning_wheel.initial_rotation = slice

func penalty():
	var keeper_parent = get_node("Keepers")
	for pos in KeeperPositions:
		var node = KeeperTemplate.instance()
		keeper_parent.add_child(node)
		node.set_pos(pos)
		node.can_attack = true
		KeeperCount += 1
		node.connect("exit_tree", self, "_on_Keeper_exit_tree", [])
		
	Player.spawn()
	
func add_reward():
	Player.set_pos(get_node("Success").get_pos())
	Player.highlight_coin(2)
	
func _on_Keeper_exit_tree():
	KeeperCount -= 1
	
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
	
	Player.set_world_size(Vector2(-7, 30), Vector2(18, -8))
	Player.restore_life()
	
	var Interactive = get_tree().get_nodes_in_group("interactive")
	for i in range(Interactive.size()):
		var node = get_node(Interactive[i].get_path())
		var args = Array([node])
		node.connect("body_enter", self, "_on_Collider_body_enter", args)
	
	var Keepers = get_tree().get_nodes_in_group("keeper")
	for i in range(Keepers.size()):
		var node = get_node(Keepers[i].get_path())
		KeeperPositions.append(node.get_pos())
		KeeperCount += 1
		print("setting: " + node.get_path())
		node.connect("exit_tree", self, "_on_Keeper_exit_tree", [])
		
	DialogParser.load_scene("spinning_wheel")
	
	Menu.connect_button_to("Comecar", self, "_on_button_comecar")
	Menu.connect_button_to("Continuar", self, "_on_button_continuar")
	Menu.connect_button_to("Terminar", self, "_on_button_terminar")

	Menu.connect("menu_on", self, "_on_menu")
	Menu.hide()
	Menu.set_middle()
	
	Player.highlight_coin(1)
	Player.spawn()


func _on_Area2D_body_enter( body ):
	if(body == Player):
		get_tree().change_scene("res://the_decision.tscn")