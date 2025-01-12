extends Node

signal treasure_scored

@onready var confetti_packed_scene = preload("res://Effects/confetti_explosion.tscn")

@export var player_index:int;

func _on_area_3d_area_entered(area: Area3D) -> void:
	print(area)
	if area.get_parent() is Player:
		var player_hit = area.get_parent() as Player
		if player_index == player_hit.player_index && !player_hit.dead:
			if player_hit.unload_cargo():
				$AudioStreamPlayer.play()
				var confetti = confetti_packed_scene.instantiate()
				get_tree().root.add_child(confetti)
				confetti.global_position = player_hit.global_position
				emit_signal("treasure_scored")
