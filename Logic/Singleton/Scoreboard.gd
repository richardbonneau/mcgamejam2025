extends Node

signal player_scored(playerIndex: int, points: int)
signal game_over(winnerIndex: int)
signal restart_game()
signal update_scoreboard(scores: Array)

@export var MAX_SCORE = 3;
var players_score = [0, 0]

var __winner:int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initializeScoreboard();
	player_scored.connect(compileScore)
	restart_game.connect(initializeScoreboard)


func initializeScoreboard():
	players_score = [0, 0];
	update_scoreboard.emit(players_score)
	
func compileScore(playerIndex: int, points: int):
	players_score[playerIndex] += points;
	if (players_score[playerIndex] >= MAX_SCORE):
		__winner = playerIndex
		get_tree().change_scene_to_file("res://Scenes/WinMenu.tscn")
		return
	update_scoreboard.emit(players_score)
	
