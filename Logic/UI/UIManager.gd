extends Node

@onready var score_label_p1:Label = $Control/Score1
@onready var score_label_p2:Label = $Control/Score2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Scoreboard.update_scoreboard.connect(updateScoreboard)


func updateScoreboard(scores: Array):
	score_label_p1.text = str(scores[0])
	score_label_p2.text = str(scores[1])
