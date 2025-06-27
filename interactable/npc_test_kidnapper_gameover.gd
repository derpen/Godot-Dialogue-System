extends InteractableCustomAction

## Overloading from base class
func _run_custom_action() -> void:
	print("Custom action has been ran")
	await get_tree().create_timer(1.0).timeout
	print("This is where a game over screen would be put if I'm not lazy")
