extends Node3D

var time := 0.0
var is_exploding := false
var player_id

func _ready():
	# Duplicate the material so each explosion has a unique copy
	var unique_mat = $Sprite3D.material_override.duplicate()
	$Sprite3D.material_override = unique_mat
	
	# Initialize explosion_time to 0
	$Sprite3D.material_override.set_shader_parameter("explosion_time", 0.0)

func start_explosion(p_id):
	player_id = p_id
	is_exploding = true
	time = 0.0
	$Area3D.monitoring = true

func _process(delta):
	if !is_exploding:
		return

	time += delta
	$Sprite3D.material_override.set_shader_parameter("explosion_time", time)

	# Auto-destroy this node after some time
	if time >= 2.0:
		queue_free()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player and body.player_index != player_id: 
		var player_hit = body
		
		if player_hit.dead: return #Don't register collision with dead players
		Health.TakeDamage.emit(player_hit.player_index, 50)
