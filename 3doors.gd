
extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

onready var Player = get_node("Player")
onready var DialogParser = get_node("DialogParser")

var KeeperCount = 0

onready var Menu = get_node("Menu").get_node("Menu")

func show_arrow(arrow):
	hide_all_arrows()
	get_node("Arrows/Arrow" + str(arrow)).show()

func hide_all_arrows():
	var arrows = get_node("Arrows").get_children()
	for arrow in arrows:
		arrow.hide()

func do_magic_effect(area, count):
	var magical_area = get_node(area)
	var magical_area_size = magical_area.get_scale() * 64
	var half_magical_area_size = magical_area_size * 0.5
	
	var magical_effect = preload("res://MagicEffect.tscn")
	
	
	randomize()
	for i in range(count):
		var pos_x = rand_range(0, magical_area_size.x) - half_magical_area_size.x 
		var pos_y = rand_range(0, magical_area_size.y) - half_magical_area_size.y
		var puf = magical_effect.instance()
		
		magical_area.add_child(puf)
		puf.set_pos(Vector2(pos_x, pos_y))
		
		
func reset():
	do_magic_effect("MagicalAreaTotal", 50)
	for i in range(1,4):
		var house = get_node("house_inside_" + str(i))
		house.get_node("Coin").hide()
		house.hide()
	hide_all_arrows()
				
func hide_house(house):
	get_node("house_inside_" + str(house)).hide()

func show_house(house):
	get_node("house_inside_" + str(house)).show()
	
func put_coin_in_house(house):
	get_node("house_inside_" + str(house) + "/Coin").show()
	
func add_reward():
	reset()
	Player.highlight_coin(1)

func _on_Collider_body_enter(body, caller):
	if(body != Player):
		return
	if(KeeperCount > 1):
		return
		
	DialogParser.start_interaction(caller.get_name())
	#Player.start_interaction(caller.get_name())

func _on_Keeper_exit_tree():
	KeeperCount -= 1
	#if(KeeperCount == 3):
	#	do_magic_effect("MagicalAreaTotal", 50)

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
	
	Player.set_world_size(Vector2(-7, 36), Vector2(21, 0))
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
	
	DialogParser.load_scene("3doors")
	Menu.connect_button_to("Comecar", self, "_on_button_comecar")
	Menu.connect_button_to("Continuar", self, "_on_button_continuar")
	Menu.connect_button_to("Terminar", self, "_on_button_terminar")

	Menu.connect("menu_on", self, "_on_menu")
	Menu.hide()
	Menu.set_middle()
	
	Player.spawn()


func _on_Area2D_body_enter( body ):
	if(body == Player and DialogParser.StateVariables["end_quest"]):
		get_tree().change_scene("res://the_roulette.tscn")