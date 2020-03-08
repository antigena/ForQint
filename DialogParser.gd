
extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

const NarrativeFilePath = "Resources/Narrative/"

const EVENT_TARGET_KEY = "eventTarget"
const START_KEY = "Start"
const NAME_KEY = "Name"
const FLAG_KEY = "Flag"
const REPEAT_KEY = "Repeat"

var Story = { }
var Events = { }
var CurrentChoices = []

var CurrentStoryBranch = null

var isChoice = false
var isChoiceDialog = false
var isScript = false
var isBlockingScript = false
var isEnd = false

var InteractingWith = null

var StateVariables = {}

var isTainted = false
var preTainted = ""

var processing = false

var input_list = []

onready var Dialog = get_node("../HUD/Dialog")
onready var Player = get_node("../Player")



func continue_the_execution():
	isBlockingScript = false

func end_quest():
	StateVariables["end_quest"] = true
	
func set_branch_to_valid_choice():
	for item in CurrentChoices:
		var conditions_meet = true
		for opt in item["ifConditions"]:
			var condition = opt["ifCondition"]
			
			if(!validate_condition(condition)):
				conditions_meet = false
				break
		if(conditions_meet):
			CurrentStoryBranch = Story["data"]["stitches"][item["linkPath"]]["content"]
			break

func is_a_script():
	for item in CurrentStoryBranch:
		if(typeof(item) != TYPE_STRING and item.has("flagName")):
			if(item["flagName"] == "run_script"):
				return true
	return false

func run_script():
	var script_source = CurrentStoryBranch[0]
	var script = GDScript.new()
	script.set_source_code("func eval():\n" + script_source)
	script.reload()
	
	#print(script_source)
	
	var obj = Node.new()
	obj.set_script(script)
	add_child(obj)
	obj.eval()
	remove_child(obj)	

func check_script():
	var script_found = false
	isBlockingScript = false
	
	for item in CurrentStoryBranch:
		if(typeof(item) != TYPE_STRING and item.has("flagName")):
			if(item["flagName"] == "run_script"):
				run_script()
				script_found = true
				
			elif(item["flagName"] == "run_blocking_script"):
				
				run_script()
				script_found = true
				isBlockingScript = true
				
			elif(StateVariables.has(item["flagName"])):
				isTainted = true
				preTainted = CurrentStoryBranch[0]
				CurrentStoryBranch[0] = CurrentStoryBranch[0] % StateVariables[item["flagName"]]
	isScript = script_found	
#		set_next_dialog(null)

func get_choices():
	CurrentChoices = []
	for item in CurrentStoryBranch:
		if(typeof(item) != TYPE_STRING and item.has("linkPath")):
			CurrentChoices.append(item)

func set_choices_values():
	var nextLinkType = get_link_type(CurrentStoryBranch[1])
	if(nextLinkType == "divert"):
		isChoice = false
		isChoiceDialog = false
	elif(nextLinkType == "linkPath" and !isChoiceDialog):
		isChoice = true
		isChoiceDialog = true
	elif(nextLinkType == "linkPath" and isChoiceDialog):
		isChoice = true
		isChoiceDialog = false
	elif(nextLinkType == "isEnd"):
		isChoice = false
		isChoiceDialog = false

func check_variable_in_option(option):
	var first_pos = option.find("%%")
	if(first_pos < 0):
		return option
	var last_pos = option.find("%%", first_pos + 1)
	if(last_pos < 0):
		return option
	var variable = option.substr(first_pos + 2, (last_pos) - (first_pos + 2))
	var text_to_replace = option.substr(first_pos, (last_pos + 2) - first_pos)
	print("the variable is: " + variable)
	var final_text = option.replace(text_to_replace, str(StateVariables[variable]))
	return final_text

func display_choices():
	Dialog.hide_interaction_text()
	Dialog.show_player()
		
	Dialog.set_n_buttons(CurrentChoices.size())
	var cont = 0
	for item in CurrentChoices:
		var option_text = check_variable_in_option(item["option"])
		Dialog.set_button_label_text(cont, option_text)
		Dialog.connect_button(cont, self, "_on_Button_pressed")
		cont += 1

func display_text(text):
	Dialog.set_interaction_text(text)
	Dialog.show_interaction_text()
	Dialog.show_wizard(InteractingWith)

func get_link_type(dialog):
	var linkType
	if(dialog.has("divert")):
		linkType = "divert"
	elif(dialog.has("linkPath")):
		if(dialog["ifConditions"] != null):
			linkType = "linkPathWithOptions"
		else:
			linkType = "linkPath"
	elif(dialog.has("isEnd")):
		linkType = "isEnd"
	return linkType
	
func set_next_dialog(target):
	var check_options_after_scripts = false
	
	if !("isEnd" in CurrentStoryBranch[1]):
		var linkType = get_link_type(CurrentStoryBranch[1])		
		if(linkType == "divert"):
			CurrentStoryBranch = Story["data"]["stitches"][CurrentStoryBranch[1]["divert"]]["content"]
		elif(linkType == "linkPathWithOptions"):
			check_options_after_scripts = true
		elif(linkType == "linkPath" and isChoiceDialog):
			get_choices()
		elif(linkType == "linkPath" and !isChoiceDialog):
#			print("the choice was: " + str(get_user_choice(target)))
			CurrentStoryBranch = Story["data"]["stitches"][CurrentStoryBranch[get_user_choice(target) + 1]["linkPath"]]["content"]
		set_choices_values()
		check_script()
		
		if(check_options_after_scripts):
			get_choices()
			set_branch_to_valid_choice()
			isScript = false
#		print(CurrentStoryBranch)
		#print(StateVariables)
	else:
		isEnd = true
		#if(is_a_script()):
		if(true):
			Dialog.hide()
			Player.set_interacting(false)
			set_fixed_process(false)
		
	
func get_user_choice(target):
	var buttonName = target.get_name()
	var id = buttonName.to_int()
	return id
	
func lookup_event(target):
	return Events[EVENT_TARGET_KEY][target]

func choose_dialog(branches):
	for item in branches:
		if (item != START_KEY and item != REPEAT_KEY):
			return branches[item][NAME_KEY]
	return null

func choose_dialog_branch(target):
	var branches = lookup_event(target)
	var choosen_branch = choose_dialog(branches)
	if(choosen_branch != null):
		return choosen_branch
	elif(!branches[START_KEY][FLAG_KEY]):
		branches[START_KEY][FLAG_KEY] = true
		return branches[START_KEY][NAME_KEY]
	elif(branches.has(REPEAT_KEY)):
		if(!StateVariables[branches[REPEAT_KEY][FLAG_KEY]]):
			return branches[REPEAT_KEY][NAME_KEY]
	return null

func load_json_file_into(path, target):
	var FileToRead = File.new()
	FileToRead.open(path, File.READ)
	var content = (FileToRead.get_as_text())
	target.parse_json(content)
	FileToRead.close()

func load_scene(scene):
	var MainSceneFile = scene + ".json"
	var EventsSceneFile = scene + "_events.json"
#	var ChoisesSceneFile = scene + "_choices.json"
	
	load_json_file_into("res://" + NarrativeFilePath + MainSceneFile, Story)
	load_json_file_into("res://" + NarrativeFilePath + EventsSceneFile, Events)
	
func start_interaction(target):
	InteractingWith = target
	isScript = false
	isEnd = false
	isChoice = false
	isChoiceDialog = false
	isTainted = false
	
	print("Interacting with: " + target)
	target = choose_dialog_branch(target)
	
	if(target == null):
		return

	Dialog.show()
	Dialog.show_wizard(InteractingWith)
	
	Player.set_interacting(true)

	print("Starting on: " + target)
	
	CurrentStoryBranch = Story["data"]["stitches"][target]["content"]
	if(CurrentStoryBranch[1] != null):
		if(CurrentStoryBranch[1].has("divert")):
			isChoice = false
			isChoiceDialog = false
		if(CurrentStoryBranch[1].has("linkPath")):
			isChoice = true
			isChoiceDialog = true
	else:
		isEnd = true

		
	Dialog.set_interaction_text(CurrentStoryBranch[0])
	
	var DialogContinueButton = Dialog.get_node("Continue")
	DialogContinueButton.get_button().connect("pressed", self, "_on_Button_pressed", [DialogContinueButton])
	
	set_fixed_process(true)

func validate_condition(condition):
	var condition_meet = false
	var tokens = condition.split(" ", false)
	
	if(tokens.size() == 3):
		print(tokens)
		print(str(StateVariables[tokens[0]]) + " " + tokens[1] + " " +str(StateVariables[tokens[2]]))
		if(tokens[1] == "=="):
			condition_meet = (StateVariables[tokens[0]] == StateVariables[tokens[2]])
		elif(tokens[1] == "!="):
			condition_meet = (StateVariables[tokens[0]] != StateVariables[tokens[2]])
	return condition_meet

func check_conditions():
	var has_condition = false
	var condition_meet = true
	
	
	if(CurrentStoryBranch.size() > 1 and get_link_type(CurrentStoryBranch[1]) != "divert"):
		return true
	
	for item in CurrentStoryBranch:
		if(typeof(item) != TYPE_STRING and item.has("ifCondition")):
			has_condition = true
			
			var condition = item["ifCondition"]
			condition_meet = validate_condition(condition)
				
	if(!has_condition):
		return true
	return condition_meet
	
func process_dialog():
	if(processing):
		return
	
	processing = true
	
	if(isBlockingScript):
		processing = false
		return
	if(input_list.empty()):
		processing = false	
		return
		
	isScript = false
	var target = input_list.front()
	
	set_next_dialog(target)
	
	print(CurrentStoryBranch)
	#print(get_link_type(CurrentStoryBranch[1]))
	
	#if(isScript and get_link_type(CurrentStoryBranch[1]) == "divert"):
	#	print("QUE GRANDE PORRA!")

	if(isScript):
		processing = false
		return
	
	var conditions_meet = check_conditions()	
	if(!conditions_meet):
		processing = false
		return
			
	if(isChoice and !isChoiceDialog):
		display_choices()
	else:
		display_text(CurrentStoryBranch[0])
		if(isTainted):
			CurrentStoryBranch[0] = preTainted
			isTainted = false	
	
	input_list.pop_front()
	processing = false

func _on_Button_pressed(target):
	if(!Player.is_interacting()):
		return
	
	if(isBlockingScript):
		return
		
	if(isEnd):
		Dialog.hide()
		Player.set_interacting(false)
		set_fixed_process(false)
		return
		
	if(!input_list.empty()):
		return
	
	input_list.append(target)
	print(input_list)
	#TODO: clear_choices?
#	set_next_dialog(target)
#	var conditions_meet = check_conditions()

#	while(isScript or !conditions_meet):
#		isScript = false
#		set_next_dialog(target)
#		conditions_meet = check_conditions()
		
#	if(isChoice and !isChoiceDialog):
#		display_choices()
#	else:
#		display_text(CurrentStoryBranch[0])
#		if(isTainted):
#			CurrentStoryBranch[0] = preTainted
#			isTainted = false
	
func _fixed_process(delta):
	process_dialog()
	
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process_input(true)
	
	
	StateVariables["no"] = "no"
	StateVariables["yes"] = "yes"
	StateVariables["false"] = "false"
	StateVariables["true"] = "true"
	StateVariables["0"] = "0"
	StateVariables["1"] = "1"
	StateVariables["end_quest"] = false
	
	if(Dialog.is_visible()):
		Dialog.hide()
