@tool
class_name Interactable extends Node

## For now, this is just to make it so that 
## player can interact with something, and then
## a dialogue will play
@export var rotate_to_player : bool = false
@export var focus_target : Node3D ## Player will focus on this, just a Node3D

var parent_node : Node3D
var is_being_interacted : bool = false

func _ready() -> void:
	if !Engine.is_editor_hint():
		if !focus_target:
			printerr("You forgot to set focus_target for " + get_parent().name)

		parent_node = get_parent()
		if parent_node is CharacterBody3D or parent_node is StaticBody3D: ## Add more as needed. TODO: I forgot what is this for lol
			parent_node.set_collision_layer_value(3, true)


# func _physics_process(delta: float) -> void:
# 	if !Engine.is_editor_hint():
# 		## Turn slowly towards the player
# 		if is_being_interacted:
# 			pass


func _start_interact() -> void:
	for child in get_children():
		if child is Action:
			is_being_interacted = true ## TODO: Turn this off later
			child._start_action()


## TODO
## Cleaning up
## Probably will use signal
func _done_interacting() -> void:
	is_being_interacted = false


func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray = []
	var found_action : bool = false
	for child in get_children():
		if child is Action:
			found_action = true
			break

	if !focus_target:
		warnings.append("Warning: Please add a Node3D and set it as FocusTarget")
			
	if !found_action:
		warnings.append("Warning: Please add InteractableAction node as a child")

	return warnings
