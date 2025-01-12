extends CharacterBody3D

@export var base_speed = 100.0
@export var speed_curve: Curve
var direction = Vector3.ZERO
var player_id: int
var time_since_launch: float = 0.0
var initial_position: Vector3

@onready var explosion_effect = preload("res://Logic/Player/Projectiles/Torpedo/explosion.tscn")

func shoot(shoot_direction: Vector2):
	time_since_launch = 0.0
	initial_position = position
	if player_id % 2 == 0: $MISSILEGREEN.show()
	elif player_id % 2 == 1: $MISSILERED.show()
	
	direction = Vector3(shoot_direction.x, shoot_direction.y, 0).normalized()
	
	# Initialize with minimum speed
	if speed_curve:
		velocity = direction * base_speed * speed_curve.sample(0.0)
	else:
		velocity = direction * base_speed
		push_warning("No speed curve set for torpedo!")

	var angle = atan2(direction.y, direction.x)
	rotation.z = angle

func _physics_process(delta):
	if !speed_curve:
		velocity = direction * base_speed
		move_and_slide()
		return
		
	time_since_launch += delta
	position.z = 0  # Keep in 2D plane
	
	# Calculate speed multiplier from curve (0.0 to 1.0 over 1 second)
	var curve_time = minf(time_since_launch, 1.0)
	var speed_multiplier = speed_curve.sample(curve_time)
	
	# Apply speed
	var current_speed = base_speed * speed_multiplier
	velocity = direction * current_speed
	
	# Debug print every 0.1 seconds
	if int(time_since_launch * 10) != int((time_since_launch - delta) * 10):
		print("Time: ", curve_time, " Speed Multiplier: ", speed_multiplier, " Current Speed: ", current_speed)
	
	move_and_slide()
	rotation.z = atan2(velocity.y, velocity.x)

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.get_parent() is Player:
		var player_hit = area.get_parent() as Player
		if player_hit.dead: return #Don't register collision with dead players
		if player_hit.player_index == player_id: return
		Health.TakeDamage.emit(player_hit.player_index, 50)
		
	# Spawn explosion effect at torpedo's position
	var explosion = explosion_effect.instantiate()
	get_parent().add_child(explosion)
	explosion.global_position = global_position
	
	queue_free()
