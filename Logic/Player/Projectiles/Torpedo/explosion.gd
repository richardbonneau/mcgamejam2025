extends Node3D

var time := 0.0
var is_exploding := false

func _ready():
	# Duplicate the material so each explosion has a unique copy
	var unique_mat = $Sprite3D.material_override.duplicate()
	$Sprite3D.material_override = unique_mat
	
	# Initialize explosion_time to 0
	$Sprite3D.material_override.set_shader_parameter("explosion_time", 0.0)

func start_explosion():
	is_exploding = true
	time = 0.0

func _process(delta):
	if !is_exploding:
		return

	time += delta
	$Sprite3D.material_override.set_shader_parameter("explosion_time", time)

	# Auto-destroy this node after some time
	if time >= 2.0:
		queue_free()
