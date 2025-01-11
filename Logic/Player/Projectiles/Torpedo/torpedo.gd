extends CharacterBody3D

@export var speed = 200.0
var direction = Vector3.ZERO
var player_id: int

func shoot(shoot_direction: Vector2):
	# Convert the 2D direction to 3D, ignoring Z
	# and store it so we can move in _physics_process
	direction = Vector3(shoot_direction.x, shoot_direction.y, 0).normalized()
	
	# Optional: Immediately set velocity so it moves without waiting 1 frame
	velocity = direction * speed

	# Set initial rotation so the torpedo faces “forward” in the XY plane
	# We'll rotate around Z if it's truly a side scroller.
	#
	# angle in radians relative to +X is atan2(y, x)
	# But if your 3D model is oriented differently, you might offset by ±90° (π/2).
	var angle = atan2(direction.y, direction.x)
	rotation.z = angle  # If the torpedo’s forward axis is +X, this usually works.
	
	# If your model is facing “up” along +Y, for example, you might do:
	#    rotation.z = angle - PI/2
	#
	# If your model is facing “into the screen” along -Z (common default),
	# you might rotate around Y or X and offset accordingly. 
	# Adjust as needed based on your model’s default orientation.

func _physics_process(delta):
	# Because it's side view, make sure it stays at Z=0
	position.z = 0

	# Keep velocity going in the stored direction
	velocity = direction * speed
	move_and_slide()
	# Update rotation if needed (e.g. if it might curve in the future)
	# For a straight shot, you typically won't change direction mid-flight.

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.get_parent() is Player:
		var player_hit = area.get_parent() as Player
		if player_hit.player_index != player_id:
			Health.TakeDamage.emit(player_hit.player_index, 15)
