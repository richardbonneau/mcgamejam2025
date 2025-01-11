extends Node
class_name Treasure

@export var weight: float = 10
@export var worth: int = 1
@export var type: String = "idk"

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
		if (player_hit.pickup_treasure(self)):
			queue_free()
		else:
			#TODO : play a sound/highlight in red?
			pass
	
