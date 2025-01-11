extends Node

@onready var score_label:Label = $ScoreBoardLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Scoreboard.update_scoreboard.connect(updateScoreboard)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	Scoreboard.player_scored.emit(0, 1)

func updateScoreboard(scores: Array):
	print("hello" + " " +str(scores[0]))
	score_label.text = str(scores[0]) + " : " + str(scores[1]);
