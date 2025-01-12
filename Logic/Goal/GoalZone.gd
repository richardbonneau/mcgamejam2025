extends Node

@export var player_index:int;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.get_parent() is Player:
		var player_hit = area.get_parent() as Player
		if player_index == player_hit.player_index && !player_hit.dead:
			player_hit.unload_cargo()
