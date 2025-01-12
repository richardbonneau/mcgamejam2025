extends Node

func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton:
		if event.button_index == JOY_BUTTON_A and event.pressed:
			_on_start_pressed()

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Logic/Main/MainRichard.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
