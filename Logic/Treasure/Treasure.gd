extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.get_parent() is Player:
		var player_hit = area.get_parent() as Player
		if player_hit.dead: return #Don't register collision with dead players
		print(str(player_hit.player_index) + " has a treasure")
	queue_free()
