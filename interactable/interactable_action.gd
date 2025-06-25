@tool
class_name Action extends Node

@export var current_action : PossibleActions ## Will play this first, must NOT be empty
@export var next_action : PossibleActions ## Can be empty

var has_been_visited : bool = false

## This is where we would handle the shenanigans
func _start_action() -> void:
	## TODO
	## Do current action here

	## TODO
	## Make sure to skip if this one has been seen before
	## and has_been_visited can be reset if repeating
	## dialogue is required
	if has_been_visited:
		pass



	## Do next one here, if exists
	if next_action:
		pass
	

func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray = []

	if !current_action:
		warnings.append("A Current Action is needed")

	return warnings
