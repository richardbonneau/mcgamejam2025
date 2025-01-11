extends CharacterBody3D

@export var speed = 20.0
var direction = Vector3.ZERO

func _physics_process(delta):
	# Keep Z position locked
	position.z = 0
	
	if direction != Vector3.ZERO:
		# Move in the set direction
		velocity = direction * speed
		move_and_slide()
		
		# Update rotation to match movement direction
		var angle = atan2(direction.y, direction.x)
		rotation.y = angle - PI/2

func shoot(shoot_direction: Vector2):
	direction = Vector3(shoot_direction.x, shoot_direction.y, 0)
	# Set initial rotation
	var angle = atan2(direction.y, direction.x)
	rotation.y = angle - PI/2
