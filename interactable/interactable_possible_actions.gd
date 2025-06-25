@tool
class_name PossibleActions extends Resource

enum ACTION_TYPE { NORMAL_DIALOGUE, CHOICE, ITEM }

@export var action_type : ACTION_TYPE:
	set(new_action_type):
		action_type = new_action_type ## Needed?
		notify_property_list_changed()
		

var dialogues : Array[String]

## Choice related
## key would be choices, value would be the next Action to call
## key would be shown as label for Choice Buttons in Player.tscn
var choices : Dictionary[String, PossibleActions]


## Item related
## Will always check before giving
## if item already given, move on to the next action (if any)
var item_to_check : String
var item_to_give : String
var dialogues_item_check_fail : Array[String]
var dialogues_item_check_success : Array[String]

var has_given_item : bool = false ## If item given already, will just skip this


## Conditional export voodoo (why tf is this so complicated)
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

		if action_type == ACTION_TYPE.CHOICE:
			ret.append({
				"name": &"choices",
				"type": TYPE_DICTIONARY,
				"hint": PROPERTY_HINT_DICTIONARY_TYPE,
				# "hint_string" : "4:;24/17:PossibleActions", ## Same thing as below, this one is just less readable
				"hint_string" : "%d:;%d/%d:PossibleActions" % [TYPE_STRING, TYPE_OBJECT, PROPERTY_HINT_RESOURCE_TYPE],
				"usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_SCRIPT_VARIABLE
			})

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

		return ret
