extends Node

@onready var score_label:Label = $ScoreBoardLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Scoreboard.update_scoreboard.connect(updateScoreboard)


func updateScoreboard(scores: Array):
	score_label.text = str(scores[0]) + " : " + str(scores[1]);
