extends Node

var treasure_spawn_points :Array = [
	{"x":20, "y":-17, "node": null},
	{"x":15, "y":-10, "node": null},
	{"x":-10, "y":10, "node": null},
	{"x":-15, "y":15, "node": null},
	#{"x":20, "y":7, "node": null},
	{"x":1, "y":22, "node": null},
	{"x":-17, "y":-15, "node": null},
	{"x":20, "y":14, "node": null},
	{"x":-6, "y":-7, "node": null},
	{"x":5, "y":12, "node": null}
]

var current_treasure = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect to both goal zones' signals
	for goal in get_tree().get_nodes_in_group("goals"):
		goal.connect("treasure_scored", _on_treasure_scored)
	spawn()

func spawn():
	# If there's already a treasure, don't spawn another
	if current_treasure != null && is_instance_valid(current_treasure):
		return
		
	var index = randi_range(0, treasure_spawn_points.size()-1)
	var item = preload("res://Logic/Treasure/Treasure.tscn")
	var treasureInstance = item.instantiate()
	treasureInstance.weight = 10
	treasureInstance.worth = 1
	
	# Store reference to current treasure
	current_treasure = treasureInstance
	
	add_child(treasureInstance)
	treasureInstance.position = Vector3(
		treasure_spawn_points[index].x, 
		treasure_spawn_points[index].y, 
		1
	)

func _on_treasure_scored():
	# Wait a short delay before spawning new treasure
	await get_tree().create_timer(0.5).timeout
	spawn()
