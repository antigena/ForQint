
extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

onready var Player = get_node("Player")
onready var DialogParser = get_node("DialogParser")
onready var Coins = get_node("HUD/coins")
onready var Coin = get_node("HUD/Coin")

var KeeperCount = 0
var CoinSide = 0
var attempts = 0
var current_I = 0

var n_mini_coins = 0

onready var Menu = get_node("Menu").get_node("Menu")

func _on_end_titles_end():
	Menu.set_end()
	Menu.show()
	
func _on_timer_timeout():
	get_node("EndTitles/Panel").connect("end_titles_end", self, "_on_end_titles_end")
	get_node("EndTitles/Panel").show()
	pause(true)

func gran_finale():
	Coins.hide()
	Coin.hide()
	
	var pos = get_node("Wizard5").get_pos()
	var magic = preload("res://MagicEffect.tscn")
	var magic_node = get_node("Magic")
	for i in range(50):
		var node = magic.instance()
		var x = rand_range(-20, 20)
		var y = rand_range(-20, 20)
		var pos_f = pos + Vector2(x,y)
		add_child(node)
		node.set_pos(pos_f)
	get_node("Wizard5").queue_free()
	
	var timer = Timer.new()
	timer.connect("timeout", self, "_on_timer_timeout")
	timer.set_wait_time(4)
	timer.set_one_shot(true)
	add_child(timer)
	timer.start()
	

func penalty():
	get_tree().reload_current_scene()

func _on_Collider_body_enter(body, caller):
	if(body != Player):
		return
	
	if(KeeperCount > 1):
		return
	Player.restore_life()
	DialogParser.start_interaction(caller.get_name())

func _on_Keeper_exit_tree():
	KeeperCount -= 1

func spin_the_coin():
	randomize()
	if(!Coin.is_visible()):
		Coin.show()
	CoinSide = round(rand_range(0, 1))
	print("Coin random: " + str(CoinSide))
	if (CoinSide > 1):
		CoinSide = 1
	Coin.spin(4, CoinSide)

func show_mini_coin(side):
	if(attempts < n_mini_coins):
		get_node("HUD/coins/coin" + str(attempts)).show()
		get_node("HUD/coins/coin" + str(attempts)).set_head_or_tails(side)

func _on_coin_end_spin():
	if(CoinSide == 1):
		current_I += 1
		Player.player_hit()
	show_mini_coin(CoinSide)
	attempts += 1
	DialogParser.continue_the_execution()

func get_coin_side():
	return CoinSide

func get_player_life():
	return Player.life
	
func get_current_probability():
	return "%d/%d" % [current_I, attempts]

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
	Player.set_world_size(Vector2(-16, 18), Vector2(18, -4))
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
#		node.can_attack = false
		
	var MiniCoins = get_node("HUD/coins").get_children()
	for item in MiniCoins:
		item.hide()
		n_mini_coins += 1
	
	Coin.connect("end_spin", self, "_on_coin_end_spin")
	
	DialogParser.load_scene("final")
	
	Menu.connect_button_to("Comecar", self, "_on_button_comecar")
	Menu.connect_button_to("Continuar", self, "_on_button_continuar")
	Menu.connect_button_to("Terminar", self, "_on_button_terminar")

	Menu.connect("menu_on", self, "_on_menu")
	Menu.hide()
	Menu.set_middle()
	
	Player.highlight_coin(1)
	Player.highlight_coin(2)
	Player.highlight_coin(3)
	Player.spawn()
	