class_name DialogueHandler extends Control

@export var character_cooldown : float = 0.01 ## How long before showing the next character
@export var sentence_cooldown : float = 1.0 ## How long before showing the next sentence

@export_group("Default values; Do not touch")
@export var dialogue_label : RichTextLabel
@export var choice_container : Control
@export var choice_one : Button
@export var choice_two : Button

signal dialogue_ended

func _dialogue_play(dialogues: Array[String]) -> void:
	for sentence in dialogues:
		dialogue_label.text = ""
		await _show_characters(sentence)
		await get_tree().create_timer(sentence_cooldown).timeout

	dialogue_label.text = ""
	emit_signal("dialogue_ended")


func _show_characters(sentence: String) -> void:
	for characters in sentence:
		dialogue_label.text += characters
		await get_tree().create_timer(character_cooldown).timeout


func _choices_show(choices_values: Dictionary) -> void:
	#GlobalScripts.emit_signal("set_player_state", 1) ## Set to interacting again, lol
	choice_container.visible = true
	choice_one.text = choices_values["choice_one"]
	choice_two.text = choices_values["choice_two"]


func _choices_pick(which_choice: int) -> void:
	#GlobalScripts.emit_signal("change_mouse_mode", Input.MOUSE_MODE_CAPTURED)
	#if which_choice == 0: ## First choice (left)
		#GlobalScripts.emit_signal("choice_one")
	#elif which_choice == 1: ## Second choice (right)
		#GlobalScripts.emit_signal("choice_two")
	
	choice_container.visible = false


func _on_choice_one_pressed() -> void:
	_choices_pick(0)


func _on_choice_two_pressed() -> void:
	_choices_pick(1)
