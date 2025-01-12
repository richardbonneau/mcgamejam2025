extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var winner = "Green" if Scoreboard.__winner == 0 else "Red"
	$WinnerLabel.text = winner+" player has won the game!"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://Logic/Main/MainRichard.tscn")
	
func _on_mainmenu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
	
func _on_quit_pressed() -> void:
	get_tree().quit()
