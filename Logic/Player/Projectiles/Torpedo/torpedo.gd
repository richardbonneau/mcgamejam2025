extends CharacterBody3D

@export var base_speed = 100.0
@export var speed_curve: Curve
var direction = Vector3.ZERO
var player_id: int
var time_since_launch: float = 0.0
var initial_position: Vector3

@onready var collision_shape = $Area3D

func shoot(shoot_direction: Vector2, player_index: int):
	$AudioStreamPlayer.play()
	player_id = player_index
	time_since_launch = 0.0
	initial_position = position
	
	# Set visual based on player index
	if player_id % 2 == 0: 
		$MISSILEGREEN.show()
		# Set collision mask for player 0's torpedo (layer 2)
		collision_shape.set_collision_mask_value(2, false)  # Disable collision with player 0
		collision_shape.set_collision_mask_value(3, true)   # Enable collision with player 1
	elif player_id % 2 == 1: 
		$MISSILERED.show()
		# Set collision mask for player 1's torpedo (layer 3)
		collision_shape.set_collision_mask_value(2, true)   # Enable collision with player 0
		collision_shape.set_collision_mask_value(3, false)  # Disable collision with player 1
	
	# Enable collision with map objects (layer 1)
	collision_shape.set_collision_mask_value(1, true)
	
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
	
	## Debug print every 0.1 seconds
	#if int(time_since_launch * 10) != int((time_since_launch - delta) * 10):
		#print("Time: ", curve_time, " Speed Multiplier: ", speed_multiplier, " Current Speed: ", current_speed)
	
	move_and_slide()
	rotation.z = atan2(velocity.y, velocity.x)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is LevelCollision: explode()
	elif body is Player and body.player_index != player_id: explode()

func explode():
	$Explosion.play()
	velocity = Vector3.ZERO
	direction = Vector3.ZERO
	set_physics_process(false)  # Stop physics processing
	$MISSILEGREEN.hide()
	$MISSILERED.hide()
	$Area3D.queue_free()
	$ExplosionEffect.start_explosion(player_id)
	$ExplosionTimer.start()

func _on_explosion_timer_timeout() -> void:
	queue_free()
