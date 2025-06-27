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
# var has_chosen : bool = false

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
var item_to_check : String
var item_to_give : String
var item_next_node_fail : NodePath ## If item check failed
var item_next_node_success : NodePath ## If item check succeded
var has_given_item : bool = false ## If item given already, will just skip this node

## Can be empty
var next_action : NodePath:
	set(new_node):
		next_action = new_node
		update_configuration_warnings()


var custom_action : InteractableCustomAction

var has_been_visited : bool = false

var player_character : PlayerController

var reset_node : bool = false

## This is where we would handle the shenanigans
func _start_action() -> void:
	## Only perform action if hasn't been visited 
	if !has_been_visited:
		## If this node hasn't been visited BUT reset flag is still up
		## it means we reach the end of our resetting system
		if reset_node:
			_break_out()
		else:
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

			## Send ref to current node to player node
			player_character.dialogue_handler.current_interact_node = self

			if action_type == ACTION_TYPE.NORMAL_DIALOGUE:
				_action_handle_dialogue()

			elif action_type == ACTION_TYPE.CHOICE:
				_action_handle_choice()

			elif action_type == ACTION_TYPE.ITEM:
				_action_handle_item()
				
			elif action_type == ACTION_TYPE.CUSTOM_ACTION:
				_action_handle_custom_action()
	else:
		_start_next_action()


func _start_next_action() -> void:
	## Do next one here, if exists
	## This has been visited
	has_been_visited = true

	if next_action:
		var next : InteractableAction = get_node(next_action) as InteractableAction

		## Check if we're going up the tree, which means we are recursing back
		## When that happens, we want to reset the tree, and stop the interaction
		## To do that, we set a flag for every node onward so we know to reset it
		## We check the first element of NodePath
		## If it's "..", then we can be sure it's recursive
		var regex = RegEx.new()
		regex.compile("\\.\\.") ## This is giga dumb
		var result = regex.search(next_action.get_name(0))
		if result:
			has_been_visited = false ## Reset current node
			next.reset_node = true
		
		## If we are already reset node, we clear the flags for this one
		## then we ALSO set the next one as reset
		if reset_node:
			next.reset_node = true
			has_been_visited = false
			reset_node = false

		next._start_action()

	else:
		_break_out()


## Breaking out of the tree
func _break_out() -> void:
	## No more action, release player
	player_character._set_player_state_walking()

	## Final nodes will always be repeating
	has_been_visited = false 
	reset_node = false


# func _clear_interact_tree() -> void:
# 	has_been_visited = false
# 	_start_next_action()
		

func _action_handle_dialogue() -> void:
	player_character.dialogue_handler._dialogue_play(dialogues)


func _action_handle_choice() -> void:
	player_character.dialogue_handler._choices_show(choices)

	# if !has_chosen:
	# 	## Send choices data to handler
	# 	has_chosen = true
	# 	player_character.dialogue_handler._choices_show(choices)

	# else:
	# 	## Else, just go straight to next_action
	# 	## I think this is not needed?
	# 	## Since if node has been visited,
	# 	## this function will never be called anyway
	# 	_start_next_action()


func _action_handle_choice_picked(which_choice : NodePath) -> void:
	## Whatever is chosen is then assigned to next_action
	next_action = which_choice
	_start_next_action()
	

func _action_handle_item() -> void:
	var does_item_exist : bool = player_character._check_item(item_to_check)
	if does_item_exist:

		## Optionally removes item from inventory
		# player_character._remove_item(item_to_check)

		next_action = item_next_node_success

		## Also give item if any
		if !item_to_give.is_empty():
			player_character._give_item(item_to_give)


	else:
		next_action = item_next_node_fail

	_start_next_action()


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
				"name": &"item_next_node_fail",
				"type": TYPE_NODE_PATH,
				"hint" : PROPERTY_HINT_NODE_TYPE,
				"hint_string" : "InteractableAction",
				"usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_SCRIPT_VARIABLE
			})

			ret.append({
				"name": &"item_next_node_success",
				"type": TYPE_NODE_PATH,
				"hint" : PROPERTY_HINT_NODE_TYPE,
				"hint_string" : "InteractableAction",
				"usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_SCRIPT_VARIABLE
			})

			# ret.append({
			# 	"name": &"next_action",
			# 	"type": TYPE_NODE_PATH,
			# 	"hint" : PROPERTY_HINT_NODE_TYPE,
			# 	"hint_string" : "InteractableAction",
			# 	"usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_SCRIPT_VARIABLE
			# })

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


## Make sure that next_action is NEVER a sibling
func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray = []

	if next_action:
		var next = get_node(next_action)
		if next is not InteractableAction:
			warnings.append("
			Please only add InteractableAction nodes
			")

		if next.get_parent() == get_parent():
			warnings.append("
			Warning: Next Action must NOT be a sibling node or itself. 
			Please change to either a parent, a child, or leave it empty
			")

	return warnings
