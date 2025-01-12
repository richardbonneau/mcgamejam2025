extends Node3D

func _ready() -> void:
	$GPUParticles3D.emitting = true
	# Wait for particles to finish
	await get_tree().create_timer(2.0).timeout
	queue_free()
