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

@onready var timer:Timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.start()
	timer.connect("timeout", spawn)
	spawn()


func spawn():
	var initial_index = randi_range(0, treasure_spawn_points.size()-1)
	var index = initial_index
	while true:
		var treasure = treasure_spawn_points[index].node
		if treasure != null && is_instance_valid(treasure):
			break # There's a treasure there!
		else:
			var item = preload ("res://Logic/Treasure/Treasure.tscn")
			var treasureInstance = item.instantiate()
			treasureInstance.weight = 10
			treasureInstance.worth = 1
			treasure_spawn_points[index].node = treasureInstance
			add_child(treasureInstance)
			treasureInstance.position = Vector3(\
				treasure_spawn_points[index].x, treasure_spawn_points[index].y, 1\
			)
			break
		index = (index + 1) % treasure_spawn_points.size()
		if initial_index != index: break
