extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.connect("timeout", Scoreboard.endGame)
	$Timer.start()
	$UI/TimerLabel.text = str(floor($Timer.get_time_left()))
	var players: Node = $Players
	var i = 0
	for player in players.get_children():
		for base_action in InputMap.get_actions():
			# Ensure the action hasn't already been added in another scene
			if not base_action.ends_with(str(i)):
				_duplicate_action(base_action, i)
		i += 1

func _process(delta:float) -> void:
	$UI/TimerLabel.text = str(floor($Timer.get_time_left()))

func _duplicate_action(base_action: String, controllerIndex:int):
	var new_action = base_action + str(controllerIndex)
	for event in InputMap.action_get_events(base_action):
		if event is InputEventJoypadButton or event is InputEventJoypadMotion:
			if not InputMap.has_action(new_action):
				var base_deadzone = InputMap.action_get_deadzone(base_action)
				InputMap.add_action(new_action, base_deadzone)
			
			var new_event = event.duplicate()
			new_event.device = controllerIndex;
			
			InputMap.action_add_event(new_action, new_event)
