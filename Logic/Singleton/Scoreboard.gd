extends Node

signal player_scored(playerIndex: int, points: int)
signal game_over(winnerIndex: int)
signal restart_game()

@export var MAX_SCORE = 3;
var players_score = [0, 0]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initializeScoreboard();
	player_scored.connect(compileScore)
	restart_game.connect(initializeScoreboard)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func initializeScoreboard():
	players_score = [0, 0];

func compileScore(playerIndex: int, points: int):
	players_score[playerIndex] += points;
	if (players_score[playerIndex] >= MAX_SCORE):
		game_over.emit(playerIndex)
