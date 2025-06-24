class_name Interactable extends Node

## For now, this is just to make it so that 
## player can interact with something, and then
## a dialogue will play
@export var rotate_to_player : bool = false
@export var focus_target : Node3D ## Player will focus on this, just a Node3D
@export_multiline var dialogues : Array[String]

var parent_node : Node3D

func _ready() -> void:
	if !focus_target:
		printerr("You forgot to set focus_target for " + get_parent().name)

	parent_node = get_parent()
	if parent_node is CharacterBody3D or parent_node is StaticBody3D: ## Add more as needed. TODO: I forgot what is this for lol
		parent_node.set_collision_layer_value(3, true)
