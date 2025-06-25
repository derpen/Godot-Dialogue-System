@tool
class_name InteractableAction extends Node

## A lot of voodoos in this file
## Apologies

enum ACTION_TYPE { NORMAL_DIALOGUE, CHOICE, ITEM, CUSTOM_ACTION }

@export var action_type : ACTION_TYPE:
	set(new_action_type):
		action_type = new_action_type ## Needed?
		notify_property_list_changed()
# 		_print_properties()

		
# func _print_properties() -> void:
# 	print( get_script().get_script_property_list() )


var dialogues : Array[String]

## Choice related
## key would be choices, value would be the next Action to call
## key would be shown as label for Choice Buttons in player.tscn
var choices : Dictionary[String, NodePath]
var has_chosen : bool = false

## Item related
## Will always perform check before perform giving
## if item already given, move on to the next action (if any)
## In this example, the player inventory is handled in player.gd
##
## Leave item_to_give as empty if you just want to trigger
## something, say, an NPC wants a key before he lets you 
## move on ahead.
## 
## Conversely, leave item_to_check as empty if you
## want an NPC to give something for free to the player
##
var item_to_check : String
var item_to_give : String
var dialogues_item_check_fail : Array[String]
var dialogues_item_check_success : Array[String]
var has_given_item : bool = false ## If item given already, will just skip this node

var next_action : NodePath ## Can be empty

var custom_action : InteractableCustomAction

var has_been_visited : bool = false

var player_character : PlayerController

## This is where we would handle the shenanigans
func _start_action() -> void:
	## Only perform action if hasn't been visited 
	if !has_been_visited:
		has_been_visited = true

		## Grab reference to player_character from Interactable parent
		## Hacky, but should work
		## An optimization is to always send ref to player_character
		## everytime we traverse down the tree, so it won't have to move
		## up the tree again everytime
		var parent = get_parent()
		while(parent is not Interactable):
			parent = parent.get_parent()
		
		parent = parent as Interactable
		player_character = parent.player_node

		# _reset_node()

		if action_type == ACTION_TYPE.NORMAL_DIALOGUE:
			_action_handle_dialogue()

		elif action_type == ACTION_TYPE.CHOICE:
			_action_handle_choice()

		elif action_type == ACTION_TYPE.ITEM:
			_action_handle_item()
			
		elif action_type == ACTION_TYPE.CUSTOM_ACTION:
			_action_handle_custom_action()


func _start_next_action() -> void:
	## Do next one here, if exists
	if next_action:
		var next : InteractableAction = get_node(next_action) as InteractableAction
		next._start_action()

	else:
		## No more action, release player
		player_character._set_player_state_walking()

		## Final nodes will always be repeating
		has_been_visited = false 
		

# ## Not sure if this is needed but we'll see
# func _reset_node() -> void:
# 	player_character.dialogue_handler.dialogue_ended.disconnect(_start_next_action)


func _action_handle_dialogue() -> void:
	## Send this to player
	player_character.dialogue_handler._dialogue_play(dialogues)



	## SIGNAL IS A DOGSHIT IDEA
	# player_character.dialogue_handler.dialogue_ended.connect(_start_next_action)


func _action_handle_choice() -> void:
	## Whatever is chosen is then assigned to next_action
	# has_chosen = true
	# if !has_chosen:
	# 	## Do the action here
	# 	pass
	# 	next_action = chosen_choice
	# else:
	#	## Else, just go straight to next_action
	#	pass
	pass
	

func _action_handle_item() -> void:
	pass


## Can add custom scripts here
## Can be used if for example,
## interacting with an pickup-able item, and then
## you want to queue_free() the item from the ground
## or if a certain choice option should trigger certain flag
func _action_handle_custom_action() -> void:
	pass


## Conditional export voodoo (why tf is this so complicated)
## Those commented can probably be removed, not sure tho 
func _get_property_list():
	if Engine.is_editor_hint():
		var ret : Array[Dictionary] = []
		if action_type == ACTION_TYPE.NORMAL_DIALOGUE:
			ret.append({
				"name": &"dialogues",
				"type": TYPE_ARRAY,
				"hint_string" : "%d/%d:" % [TYPE_STRING, PROPERTY_HINT_MULTILINE_TEXT],
				"usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_SCRIPT_VARIABLE
			})

			ret.append({
				"name": &"next_action",
				"type": TYPE_NODE_PATH,
				"hint" : PROPERTY_HINT_NODE_TYPE,
				"hint_string" : "InteractableAction",
				"usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_SCRIPT_VARIABLE
			})

			# ret.append({
			# 	"name": &"next_action",
			# 	"type": TYPE_NODE_PATH,
			# 	"hint" : PROPERTY_HINT_NODE_TYPE,
			# 	"hint_string" : "NodePath",
			# 	"usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_SCRIPT_VARIABLE
			# })

		if action_type == ACTION_TYPE.CHOICE:
			ret.append({
				"name": &"choices",
				"type": TYPE_DICTIONARY,
				# "hint": PROPERTY_HINT_DICTIONARY_TYPE,
				"hint_string" : "%d:;%d/%d:InteractableAction" % [TYPE_STRING, TYPE_NODE_PATH, PROPERTY_HINT_NODE_TYPE],
				"usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_SCRIPT_VARIABLE
			})

			# ret.append({
			# 	"name": &"choices",
			# 	"type": TYPE_DICTIONARY,
			# 	# "hint": PROPERTY_HINT_DICTIONARY_TYPE,
			# 	"hint_string" : "%d:;%d/%d:NodePath" % [TYPE_STRING, TYPE_NODE_PATH, PROPERTY_HINT_NODE_TYPE],
			# 	"usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_SCRIPT_VARIABLE
			# })

		if action_type == ACTION_TYPE.ITEM:
			ret.append({
				"name": &"item_to_check",
				"type": TYPE_STRING,
				"usage": PROPERTY_USAGE_DEFAULT,
			})
			ret.append({
				"name": &"item_to_give",
				"type": TYPE_STRING,
				"usage": PROPERTY_USAGE_DEFAULT,
			})
			ret.append({
				"name": &"dialogues_item_check_fail",
				"type": TYPE_ARRAY,
				"hint_string" : "%d/%d:" % [TYPE_STRING, PROPERTY_HINT_MULTILINE_TEXT],
				"usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_SCRIPT_VARIABLE
			})
			ret.append({
				"name": &"dialogues_item_check_success",
				"type": TYPE_ARRAY,
				"hint_string" : "%d/%d:" % [TYPE_STRING, PROPERTY_HINT_MULTILINE_TEXT],
				"usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_SCRIPT_VARIABLE
			})

			ret.append({
				"name": &"next_action",
				"type": TYPE_NODE_PATH,
				"hint" : PROPERTY_HINT_NODE_TYPE,
				"hint_string" : "InteractableAction",
				"usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_SCRIPT_VARIABLE
			})

			# ret.append({
			# 	"name": &"next_action",
			# 	"type": TYPE_NODE_PATH,
			# 	"hint" : PROPERTY_HINT_NODE_TYPE,
			# 	"hint_string" : "NodePath",
			# 	"usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_SCRIPT_VARIABLE
			# })

		if action_type == ACTION_TYPE.CUSTOM_ACTION:
			ret.append({
				"name": &"custom_action",
				"type": TYPE_OBJECT,
				"hint" : PROPERTY_HINT_NODE_TYPE,
				"hint_string" : "InteractableCustomAction",
				"usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_SCRIPT_VARIABLE
			})

			ret.append({
				"name": &"next_action",
				"type": TYPE_NODE_PATH,
				"hint" : PROPERTY_HINT_NODE_TYPE,
				"hint_string" : "InteractableAction",
				"usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_SCRIPT_VARIABLE
			})
		

		return ret
