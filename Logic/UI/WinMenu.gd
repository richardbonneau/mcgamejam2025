extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if (Scoreboard.__winner == -1):
		$WinnerLabel.text = "Tie!"
	else:
		var winner = "Green" if Scoreboard.__winner == 0 else "Red"
		$WinnerLabel.text = winner+" player has won the game!"

func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton:
		if event.button_index == JOY_BUTTON_A and event.pressed:
			_on_restart_pressed()

func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://Logic/Main/MainRichard.tscn")
	
func _on_mainmenu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
	
func _on_quit_pressed() -> void:
	get_tree().quit()
